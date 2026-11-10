"""Generates catalog.json and CATALOG.md from scanned skills."""
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any
from core.taxonomy import CATEGORIES

def build_catalog_data(skills: List[Dict[str, Any]], active_preset: str = "custom") -> Dict[str, Any]:
    """Assemble structured catalog dictionary."""
    total = len(skills)
    active = sum(1 for s in skills if s["status"] == "active")
    disabled = total - active

    # Category summaries
    cat_counts = {}
    for s in skills:
        cid = s["category_id"]
        cat_counts[cid] = cat_counts.get(cid, 0) + 1

    categories_meta = []
    for c in CATEGORIES:
        cid = c["id"]
        categories_meta.append({
            "id": cid,
            "name": c["name"],
            "count": cat_counts.get(cid, 0)
        })

    return {
        "generated_at": datetime.now().isoformat(),
        "summary": {
            "total_skills": total,
            "active_skills": active,
            "disabled_skills": disabled,
            "categories_count": len([c for c in categories_meta if c["count"] > 0]),
            "active_preset": active_preset
        },
        "categories": categories_meta,
        "skills": skills
    }

def export_catalog_json(catalog_data: Dict[str, Any], output_path: Path):
    """Write catalog.json."""
    output_path.write_text(json.dumps(catalog_data, indent=2, ensure_ascii=False), encoding="utf-8")

def export_catalog_markdown(catalog_data: Dict[str, Any], output_path: Path):
    """Write comprehensive human and AI-readable CATALOG.md."""
    summary = catalog_data["summary"]
    skills = catalog_data["skills"]
    generated_time = catalog_data["generated_at"]

    lines = [
        "# 📚 AI Skill Library & Central Catalog",
        "",
        "> [!IMPORTANT]",
        f"> **System Status:** Total **{summary['total_skills']}** Skills | "
        f"**{summary['active_skills']} Active** | "
        f"**{summary['disabled_skills']} Disabled** | "
        f"Active Preset: `{summary['active_preset']}`",
        "",
        f"*Last updated: {generated_time}*",
        "",
        "## 📑 Categories Overview",
        "",
        "| Category | Skills Count | Navigation |",
        "| :--- | :---: | :--- |"
    ]

    for cat in catalog_data["categories"]:
        if cat["count"] > 0:
            anchor = cat["name"].lower().replace(" ", "-").replace("&", "").replace(",", "")
            lines.append(f"| **{cat['name']}** | {cat['count']} | [Jump to Section](#{anchor}) |")

    lines.append("")
    lines.append("---")
    lines.append("")

    # Group skills by category
    skills_by_cat: Dict[str, List[Dict[str, Any]]] = {}
    for s in skills:
        skills_by_cat.setdefault(s["category_name"], []).append(s)

    for cat_name, cat_skills in skills_by_cat.items():
        anchor_id = cat_name.lower().replace(" ", "-").replace("&", "").replace(",", "")
        lines.append(f"## {cat_name}")
        lines.append("")
        lines.append("| Status | Skill ID | Description | Source / Plugin |")
        lines.append("| :---: | :--- | :--- | :--- |")

        for s in cat_skills:
            status_icon = "🟢 `ACTIVE`" if s["status"] == "active" else "⚪ `DISABLED`"
            source_label = f"**{s['plugin_name']}**" if s["plugin_name"] else f"*{s['source_type']}*"
            
            # Escape pipes in description
            desc_safe = s["description"].replace("|", "\\|").replace("\n", " ").strip()
            if len(desc_safe) > 160:
                desc_safe = desc_safe[:157] + "..."
            if not desc_safe:
                desc_safe = "*No description provided*"

            lines.append(f"| {status_icon} | [`{s['id']}`]({Path(s['file_path']).as_uri()}) | {desc_safe} | {source_label} |")

        lines.append("")

    lines.append("---")
    lines.append("")
    lines.append("## 🛠️ Quick CLI Commands")
    lines.append("```bash")
    lines.append("# Switch preset")
    lines.append("python skill_manager.py preset apply web-fullstack")
    lines.append("python skill_manager.py preset apply mobile-app")
    lines.append("python skill_manager.py preset apply data-cloud")
    lines.append("python skill_manager.py preset apply minimal")
    lines.append("python skill_manager.py preset apply full")
    lines.append("")
    lines.append("# Search skills")
    lines.append("python skill_manager.py search \"firestore\"")
    lines.append("")
    lines.append("# Scan and update catalog")
    lines.append("python skill_manager.py scan")
    lines.append("")
    lines.append("# Run duplication and quality audit")
    lines.append("python skill_manager.py audit")
    lines.append("```")

    output_path.write_text("\n".join(lines), encoding="utf-8")
