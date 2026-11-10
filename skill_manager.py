#!/usr/bin/env python3
"""
Skill Manager CLI - Central Command for AI Skill Library
Manages cataloging, categorization, presets, pruning, and on-demand search.
"""
import sys
import os
import json
import argparse
from pathlib import Path

# Add project root to path
WORKSPACE_ROOT = Path(__file__).parent.resolve()
sys.path.insert(0, str(WORKSPACE_ROOT))

# Ensure Windows stdout handles UTF-8 / emojis
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

from core.scanner import scan_skills
from core.catalog_builder import build_catalog_data, export_catalog_json, export_catalog_markdown
from core.preset_manager import PresetManager
from core.auditor import audit_skills, format_audit_report, prune_duplicates, prune_recommendations, restore_all_skills
from core.droid_manager import DroidManager, DEFAULT_DROID_TRIO
from core.recommender import recommend_skills_for_idea

def load_config():
    config_file = WORKSPACE_ROOT / "config" / "config.json"
    with open(config_file, "r", encoding="utf-8") as f:
        return json.load(f)

def cmd_scan(args):
    print("🔄 Scanning skills across system roots...")
    cfg = load_config()
    preset_mgr = PresetManager(WORKSPACE_ROOT)
    active_preset = preset_mgr.get_active_preset()

    skills = scan_skills(cfg["scan_roots"])
    catalog_data = build_catalog_data(skills, active_preset=active_preset)

    json_path = WORKSPACE_ROOT / cfg["catalog_json"]
    md_path = WORKSPACE_ROOT / cfg["catalog_md"]

    export_catalog_json(catalog_data, json_path)
    export_catalog_markdown(catalog_data, md_path)

    summary = catalog_data["summary"]
    print(f"✅ Scan complete!")
    print(f"   Total Skills: {summary['total_skills']}")
    print(f"   Active: {summary['active_skills']} | Disabled: {summary['disabled_skills']}")
    print(f"   Active Preset: {summary['active_preset']}")
    print(f"   Catalog JSON: {json_path}")
    print(f"   Catalog MD:   {md_path}")

def cmd_preset(args):
    preset_mgr = PresetManager(WORKSPACE_ROOT)
    cfg = load_config()

    if args.preset_action == "list":
        active = preset_mgr.get_active_preset()
        print("\n📋 Available Presets:")
        print("------------------------------------------------------------")
        for pid, pdata in preset_mgr.presets.items():
            marker = "👉 [ACTIVE]" if pid == active else "   [      ]"
            print(f"{marker} {pid.ljust(16)} : {pdata.get('name', pid)}")
            print(f"                     {pdata.get('description', '')}")
        print("------------------------------------------------------------")
        print(f"Protected Core Skills: {', '.join(sorted(list(preset_mgr.protected_skills)))}\n")

    elif args.preset_action == "current":
        active = preset_mgr.get_active_preset()
        print(f"\n👉 Currently active preset: {active}\n")

    elif args.preset_action == "apply":
        target = args.preset_name
        if not target:
            print("❌ Please specify a preset name. e.g.: python skill_manager.py preset apply web-fullstack")
            return

        print(f"⚙️ Applying preset: '{target}' (Dry run: {args.dry_run})...")
        skills = scan_skills(cfg["scan_roots"])
        res = preset_mgr.apply_preset(target, skills, dry_run=args.dry_run)

        print(f"✅ Preset '{target}' applied successfully!")
        print(f"   Enabled Skills:  {res['enabled_count']}")
        print(f"   Disabled Skills: {res['disabled_count']}")
        print(f"   Files Toggled:   {res['changes_count']}")

        if not args.dry_run:
            # Re-generate catalog
            print("🔄 Updating catalog files...")
            updated_skills = scan_skills(cfg["scan_roots"])
            catalog_data = build_catalog_data(updated_skills, active_preset=target)
            export_catalog_json(catalog_data, WORKSPACE_ROOT / cfg["catalog_json"])
            export_catalog_markdown(catalog_data, WORKSPACE_ROOT / cfg["catalog_md"])
            print("✨ Catalog updated.")

def cmd_search(args):
    query = args.query.lower()
    json_path = WORKSPACE_ROOT / "catalog.json"
    if not json_path.exists():
        print("⚠️ catalog.json not found. Running scan first...")
        cmd_scan(args)

    with open(json_path, "r", encoding="utf-8") as f:
        catalog = json.load(f)

    results = []
    for s in catalog["skills"]:
        text = f"{s['id']} {s['name']} {s['description']} {' '.join(s['tags'])} {s['category_name']}".lower()
        if query in text:
            results.append(s)

    print(f"\n🔍 Search results for '{args.query}' ({len(results)} matches):")
    print("=" * 80)
    for r in results:
        status_str = "🟢 ACTIVE" if r["status"] == "active" else "⏸️ DISABLED"
        print(f"[{status_str}] {r['id']} ({r['category_name']})")
        print(f"   Description : {r['description'][:120]}...")
        print(f"   Path        : {r['file_path']}")
        print("-" * 80)
    print()

def cmd_toggle(args):
    preset_mgr = PresetManager(WORKSPACE_ROOT)
    cfg = load_config()
    skills = scan_skills(cfg["scan_roots"])

    target_status = "active" if args.enable else ("disabled" if args.disable else None)
    try:
        res = preset_mgr.toggle_skill(args.skill_id, skills, target_status=target_status)
        if not res:
            print(f"❌ Skill '{args.skill_id}' not found.")
            return

        print(f"✅ Skill '{res['id']}' set to {res['action']} -> {res['path']}")
        # Update catalog
        cmd_scan(args)
    except ValueError as e:
        print(f"❌ Error: {e}")

def cmd_audit(args):
    cfg = load_config()
    skills = scan_skills(cfg["scan_roots"])
    issues = audit_skills(skills)
    report_md = format_audit_report(issues)

    print("\n" + report_md + "\n")
    audit_file = WORKSPACE_ROOT / "AUDIT_REPORT.md"
    audit_file.write_text(report_md, encoding="utf-8")
    print(f"📄 Full audit report saved to: {audit_file}\n")

def cmd_prune(args):
    cfg = load_config()
    skills = scan_skills(cfg["scan_roots"])
    preset_mgr = PresetManager(WORKSPACE_ROOT)

    if args.duplicates:
        print(f"✂️ Pruning duplicate / redundant copies (Dry run: {args.dry_run})...")
        actions = prune_duplicates(skills, dry_run=args.dry_run)
        print(f"✅ Disabled {len(actions)} redundant duplicate copies. (Kept 1 primary copy active for each skill)")
        for a in actions[:10]:
            print(f"   - {a['id']}: Disabled redundant copy")
        if len(actions) > 10:
            print(f"   ... and {len(actions) - 10} more.")
    elif args.recommendations:
        print(f"✂️ Disabling recommended niche skills to On-Demand (Dry run: {args.dry_run})...")
        actions = prune_recommendations(skills, dry_run=args.dry_run)
        print(f"✅ Moved {len(actions)} niche skills to On-Demand (.disabled).")
        for a in actions:
            print(f"   - {a['id']}")
    elif args.restore_all:
        print(f"🔄 Restoring all disabled skills to active (Dry run: {args.dry_run})...")
        actions = restore_all_skills(skills, dry_run=args.dry_run)
        print(f"✅ Restored {len(actions)} skills to active.")
    else:
        print("ℹ️ Please specify a flag: --duplicates, --recommendations, or --restore-all")
        return

    if not args.dry_run:
        print("🔄 Updating catalog...")
        updated_skills = scan_skills(cfg["scan_roots"])
        catalog_data = build_catalog_data(updated_skills, active_preset=preset_mgr.get_active_preset())
        export_catalog_json(catalog_data, WORKSPACE_ROOT / cfg["catalog_json"])
        export_catalog_markdown(catalog_data, WORKSPACE_ROOT / cfg["catalog_md"])
        print("✨ Catalog updated.")

def cmd_recommend(args):
    idea = args.idea
    cfg = load_config()
    skills = scan_skills(cfg["scan_roots"])
    res = recommend_skills_for_idea(idea, skills)

    print("\n" + "=" * 70)
    print("💡 AI Skill & Architecture Recommendation")
    print("=" * 70)
    print(f"📌 Project Idea : \"{idea}\"")
    print(f"🎯 Recommended Preset : [{res['recommended_preset'].upper()}]")
    print("-" * 70)
    print("🛠️ Skills ที่คุณควรหยิบมาใช้ในโปรเจกต์นี้:")
    if res["skills"]:
        for s in res["skills"]:
            status_tag = "🟢 พร้อมใช้" if s["status"] == "active" else "⏸️ On-Demand"
            print(f"  • {s['id']} [{status_tag}] ({s['category']})")
            print(f"    └ {s['description'][:110]}...")
    else:
        print("  (ใช้ทักษะพื้นฐานทั่วไปใน Preset ได้เลย)")

    print("-" * 70)
    print(f"🤖 คำแนะนำถัดไป: สลับระบบไปใช้ Preset '{res['recommended_preset']}'")
    print(f"   คำสั่ง: python skill_manager.py preset apply {res['recommended_preset']}")
    
    if args.apply:
        print(f"\n⚡ กำลังสลับ Preset เป็น '{res['recommended_preset']}' อัตโนมัติ...")
        preset_mgr = PresetManager(WORKSPACE_ROOT)
        preset_mgr.apply_preset(res['recommended_preset'], skills)
        print("✨ สลับโหมดสำเร็จ! ระบบพร้อมสำหรับพัฒนาโปรเจกต์นี้แล้วครับ")
    print("=" * 70 + "\n")

def cmd_info(args):
    json_path = WORKSPACE_ROOT / "catalog.json"
    if not json_path.exists():
        cmd_scan(args)

    with open(json_path, "r", encoding="utf-8") as f:
        catalog = json.load(f)

    skill = next((s for s in catalog["skills"] if s["id"].lower() == args.skill_id.lower()), None)
    if not skill:
        print(f"❌ Skill '{args.skill_id}' not found.")
        return

    print("\n" + "=" * 60)
    print(f"📌 Skill Details: {skill['id']}")
    print("=" * 60)
    print(f"Name         : {skill['name']}")
    print(f"Status       : {'🟢 ACTIVE' if skill['status'] == 'active' else '⏸️ DISABLED'}")
    print(f"Category     : {skill['category_name']}")
    print(f"Plugin/Source: {skill['plugin_name'] or skill['source_type']}")
    print(f"File Path    : {skill['file_path']}")
    print(f"Hash         : {skill['hash']}")
    print(f"Tags         : {', '.join(skill['tags'])}")
    print(f"\nDescription:\n{skill['description']}")
    print("=" * 60 + "\n")

def cmd_init(args):
    target_path = Path(args.dir).resolve() if args.dir else Path.cwd().resolve()
    preset_name = args.preset or "web-fullstack"
    
    print(f"🚀 Initializing Factory Droids in: {target_path}")
    print(f"   Using Preset: {preset_name}")
    dm = DroidManager(WORKSPACE_ROOT)
    res = dm.init_project_droids(target_path, preset_name=preset_name)

    print("✅ Project Initialized Successfully!")
    print(f"   Droids Directory : {res['droids_dir']}")
    print(f"   Droids Configured: {res['droids_count']} (Coder, Tester, Reviewer)")
    print(f"   Workflow Pipeline: {' -> '.join(res['pipeline_sequence'])}")
    print(f"   Documentation    : {Path(res['droids_dir']) / 'DROIDS.md'}\n")

def cmd_droid(args):
    if args.droid_action == "list":
        print("\n🤖 Configured Factory Droids:")
        print("=" * 70)
        for did, d in DEFAULT_DROID_TRIO.items():
            perm = d["permissions"]["mode"]
            print(f"[{did}] {d['name']} - {d['role']} (Mode: {perm})")
            print(f"   Description : {d['description']}")
            print(f"   Skills      : {', '.join(d['recommended_skills'])}")
            print("-" * 70)
        print()
    elif args.droid_action == "info":
        did = args.droid_name
        if did not in DEFAULT_DROID_TRIO:
            print(f"❌ Droid '{did}' not found. Available: {list(DEFAULT_DROID_TRIO.keys())}")
            return
        d = DEFAULT_DROID_TRIO[did]
        print("\n" + "=" * 60)
        print(f"🤖 Droid Details: {d['name']} ({did})")
        print("=" * 60)
        print(f"Role        : {d['role']}")
        print(f"Permissions : {d['permissions']}")
        print(f"Skills      : {', '.join(d['recommended_skills'])}")
        print(f"\nSystem Prompt:\n{d['system_prompt']}")
        print("=" * 60 + "\n")

def cmd_pipeline(args):
    task = args.task
    preset = args.preset or "web-fullstack"
    print("\n" + "=" * 70)
    print("🏭 Autonomous Factory Pipeline Orchestration Plan")
    print("=" * 70)
    print(f"Task: {task}")
    print(f"Active Preset: {preset}")
    print("\n[Stage 1: Coder Droid]")
    print("  Role       : Autonomous Implementation")
    print("  Action     : Break task into subgoals, inspect codebase, implement code changes.")
    print("  Permissions: Full write and terminal access.")
    print("\n[Stage 2: Tester Droid]")
    print("  Role       : Verification & QA")
    print("  Action     : Write unit & regression tests, execute test commands, verify zero failures.")
    print("  Feedback   : If tests fail, returns concrete stacktrace & bug report to Coder Droid.")
    print("\n[Stage 3: Reviewer Droid]")
    print("  Role       : Quality & Security Gatekeeper (Read-Only)")
    print("  Action     : Check diff against project coding standards, OWASP top 10, and spec.")
    print("  Verdict    : [APPROVED] -> Proceed to PR | [CHANGES_REQUESTED] -> Loop back to Coder.")
    print("=" * 70 + "\n")

def main():
    parser = argparse.ArgumentParser(description="Skill Manager CLI")
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    # scan
    subparsers.add_parser("scan", help="Scan roots and build/update catalog.json and CATALOG.md")
    
    # preset
    p_preset = subparsers.add_parser("preset", help="Manage skill presets")
    p_preset.add_argument("preset_action", choices=["list", "apply", "current"])
    p_preset.add_argument("preset_name", nargs="?", default="", help="Name of preset to apply")
    p_preset.add_argument("--dry-run", action="store_true", help="Preview changes without renaming")

    # search
    p_search = subparsers.add_parser("search", help="Search skills by keyword")
    p_search.add_argument("query", help="Keyword to search for")

    # info
    p_info = subparsers.add_parser("info", help="Display details for a skill")
    p_info.add_argument("skill_id", help="Skill ID to inspect")

    # toggle
    p_toggle = subparsers.add_parser("toggle", help="Toggle an individual skill active/disabled")
    p_toggle.add_argument("skill_id", help="Skill ID to toggle")
    p_toggle.add_argument("--enable", action="store_true", help="Force enable")
    p_toggle.add_argument("--disable", action="store_true", help="Force disable")

    # audit
    subparsers.add_parser("audit", help="Run quality and pruning audit")

    # prune
    p_prune = subparsers.add_parser("prune", help="Prune duplicate copies or recommended niche skills")
    p_prune.add_argument("--duplicates", action="store_true", help="Disable redundant duplicate copies (keep 1 primary)")
    p_prune.add_argument("--recommendations", action="store_true", help="Disable audit-recommended niche skills")
    p_prune.add_argument("--restore-all", action="store_true", help="Restore all disabled skills back to active")
    p_prune.add_argument("--dry-run", action="store_true", help="Preview pruning actions without modifying files")

    # recommend
    p_rec = subparsers.add_parser("recommend", help="Analyze your project idea and recommend the best preset and skills")
    p_rec.add_argument("idea", help="Description of what you want to build (Thai or English)")
    p_rec.add_argument("--apply", action="store_true", help="Automatically apply the recommended preset")

    # init (Factory project init)
    p_init = subparsers.add_parser("init", help="Initialize Factory Droids and scoped skills in a project")
    p_init.add_argument("--dir", default="", help="Target directory (default: current directory)")
    p_init.add_argument("--preset", default="web-fullstack", help="Preset to apply for this project")

    # droid
    p_droid = subparsers.add_parser("droid", help="Inspect and manage Factory Droids")
    p_droid.add_argument("droid_action", choices=["list", "info"])
    p_droid.add_argument("droid_name", nargs="?", default="", help="Droid name for info")

    # pipeline
    p_pipeline = subparsers.add_parser("pipeline", help="Orchestrate an autonomous Coder -> Tester -> Reviewer pipeline")
    p_pipeline.add_argument("task", help="Description of task to implement")
    p_pipeline.add_argument("--preset", default="web-fullstack", help="Preset to use")

    args = parser.parse_args()

    if args.subcommand in ("scan", "update"):
        cmd_scan(args)
    elif args.subcommand == "preset":
        cmd_preset(args)
    elif args.subcommand == "search":
        cmd_search(args)
    elif args.subcommand == "info":
        cmd_info(args)
    elif args.subcommand == "toggle":
        cmd_toggle(args)
    elif args.subcommand == "audit":
        cmd_audit(args)
    elif args.subcommand == "prune":
        cmd_prune(args)
    elif args.subcommand == "recommend":
        cmd_recommend(args)
    elif args.subcommand == "init":
        cmd_init(args)
    elif args.subcommand == "droid":
        cmd_droid(args)
    elif args.subcommand == "pipeline":
        cmd_pipeline(args)

if __name__ == "__main__":
    main()
