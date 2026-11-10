"""Auditor for analyzing skill quality, overlaps, duplicates, and pruning candidates."""
import re
from pathlib import Path
from typing import Dict, List, Any, Tuple
from collections import defaultdict

def audit_skills(skills: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Analyze all skills for quality, duplicates, and redundancies."""
    issues = {
        "duplicates": [],
        "missing_descriptions": [],
        "overlap_clusters": [],
        "pruning_recommendations": []
    }

    # 1. Exact or near ID duplicates
    id_map = defaultdict(list)
    for s in skills:
        id_map[s["id"]].append(s)

    for sid, s_list in id_map.items():
        if len(s_list) > 1:
            issues["duplicates"].append({
                "skill_id": sid,
                "count": len(s_list),
                "paths": [s["file_path"] for s in s_list]
            })

    # 2. Missing or low quality descriptions
    for s in skills:
        desc = s["description"].strip()
        if not desc or len(desc) < 25:
            issues["missing_descriptions"].append({
                "skill_id": s["id"],
                "file_path": s["file_path"],
                "length": len(desc)
            })

    # 3. Functional overlap clusters (heuristics on prefixes and tags)
    clusters = defaultdict(list)
    for s in skills:
        # Group by prefix before hyphen
        prefix = s["id"].split("-")[0] if "-" in s["id"] else s["id"].split("_")[0]
        if prefix in ("gcp", "google", "bigquery", "flutter", "dart", "figma", "netlify", "vercel", "firebase"):
            clusters[prefix].append(s["id"])

    for prefix, group in clusters.items():
        if len(group) >= 5:
            issues["overlap_clusters"].append({
                "cluster_name": prefix,
                "skill_count": len(group),
                "skills_sample": group[:8]
            })

    # 4. Pruning recommendations (skills that heavily bloat context when unused)
    pruning_candidates = []
    seen_cand = set()
    for s in skills:
        sid = s["id"]
        if sid in seen_cand:
            continue
        if any(keyword in sid for keyword in [
            "bigquery-graph", "spark-troubleshooting", "composer-troubleshooting",
            "managed-airflow", "extension-to-functions", "checks-package",
            "dart-use-ffigen", "dart-use-pattern", "figma-shaders"
        ]):
            seen_cand.add(sid)
            pruning_candidates.append({
                "skill_id": sid,
                "category": s["category_name"],
                "file_path": s["file_path"],
                "status": s["status"],
                "reason": "Highly specialized / niche skill. Recommended to load on-demand via Librarian rather than keeping in active prompt."
            })

    issues["pruning_recommendations"] = pruning_candidates
    return issues

def prune_duplicates(skills: List[Dict[str, Any]], dry_run: bool = False) -> List[Dict[str, str]]:
    """Disable duplicate copies (like upstream, skills-figquery, codex) keeping 1 primary copy active."""
    id_map = defaultdict(list)
    for s in skills:
        id_map[s["id"]].append(s)

    actions = []
    for sid, s_list in id_map.items():
        if len(s_list) <= 1:
            continue

        # Sort so primary canonical path is first
        def score_path(skill_obj):
            p = skill_obj["file_path"].lower().replace("\\", "/")
            if "/upstream/" in p:
                return 10
            if "/skills-figquery/" in p:
                return 8
            if "/codex/" in p:
                return 6
            if "/agent-plugin/" in p:
                return 4
            return 0

        sorted_skills = sorted(s_list, key=score_path)
        primary = sorted_skills[0]
        duplicates = sorted_skills[1:]

        for dup in duplicates:
            if dup["status"] == "active":
                cur_path = Path(dup["file_path"])
                target_path = cur_path.parent / "SKILL.md.disabled"
                if not dry_run and cur_path.exists():
                    cur_path.rename(target_path)
                dup["status"] = "disabled"
                dup["file_path"] = str(target_path)
                actions.append({
                    "id": sid,
                    "action": "DISABLED_DUPLICATE",
                    "original": str(cur_path),
                    "kept_primary": primary["file_path"]
                })

    return actions

def prune_recommendations(skills: List[Dict[str, Any]], dry_run: bool = False) -> List[Dict[str, str]]:
    """Disable specialized niche skills recommended by the audit, moving them to on-demand."""
    audit_data = audit_skills(skills)
    recs = audit_data["pruning_recommendations"]
    target_ids = {r["skill_id"] for r in recs}

    actions = []
    for s in skills:
        if s["id"] in target_ids and s["status"] == "active":
            cur_path = Path(s["file_path"])
            target_path = cur_path.parent / "SKILL.md.disabled"
            if not dry_run and cur_path.exists():
                cur_path.rename(target_path)
            s["status"] = "disabled"
            s["file_path"] = str(target_path)
            actions.append({
                "id": s["id"],
                "action": "DISABLED_RECOMMENDED",
                "path": str(target_path)
            })

    return actions

def restore_all_skills(skills: List[Dict[str, Any]], dry_run: bool = False) -> List[Dict[str, str]]:
    """Restore all disabled skills back to active."""
    actions = []
    for s in skills:
        if s["status"] == "disabled":
            cur_path = Path(s["file_path"])
            target_path = cur_path.parent / "SKILL.md"
            if not dry_run and cur_path.exists():
                cur_path.rename(target_path)
            s["status"] = "active"
            s["file_path"] = str(target_path)
            actions.append({
                "id": s["id"],
                "action": "RESTORED_ACTIVE",
                "path": str(target_path)
            })
    return actions

def format_audit_report(issues: Dict[str, Any]) -> str:
    """Format audit results as readable markdown."""
    lines = [
        "# 🔍 Skill Library Quality & Pruning Audit Report",
        "",
        "## 1. ⚠️ Duplicates & ID Collisions",
    ]
    if issues["duplicates"]:
        for d in issues["duplicates"]:
            lines.append(f"- **`{d['skill_id']}`** ({d['count']} occurrences):")
            for p in d["paths"]:
                lines.append(f"  - `{p}`")
    else:
        lines.append("- *No identical ID collisions found.*")

    lines.append("")
    lines.append("## 2. 📝 Missing / Brief Descriptions (< 25 chars)")
    if issues["missing_descriptions"]:
        lines.append(f"- Found **{len(issues['missing_descriptions'])}** skills with weak descriptions:")
        for m in issues["missing_descriptions"][:10]:
            lines.append(f"  - `{m['skill_id']}` ({m['length']} chars)")
        if len(issues['missing_descriptions']) > 10:
            lines.append(f"  - *...and {len(issues['missing_descriptions']) - 10} more.*")
    else:
        lines.append("- *All skills have satisfactory descriptions.*")

    lines.append("")
    lines.append("## 3. 📦 High-Density Functional Clusters")
    for c in issues["overlap_clusters"]:
        lines.append(f"- **{c['cluster_name'].upper()}**: {c['skill_count']} skills (e.g., {', '.join(c['skills_sample'][:5])}...)")

    lines.append("")
    lines.append("## 4. ✂️ Pruning / On-Demand Candidates")
    lines.append(f"Identified **{len(issues['pruning_recommendations'])}** specialized skills ideal for on-demand Librarian routing:")
    for p in issues["pruning_recommendations"]:
        lines.append(f"- **`{p['skill_id']}`** ({p['category']}): {p['reason']}")

    return "\n".join(lines)
