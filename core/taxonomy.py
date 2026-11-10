"""Taxonomy classification engine for skills."""
import re
from typing import Dict, List, Tuple

CATEGORIES = [
    {
        "id": "engineering_rigor",
        "name": "Production Rigor & pstack",
        "keywords": ["pstack", "poteto", "principle", "deslop", "unslop", "architect", "arena", "swarm", "interrogate", "forensic", "hillclimb", "rigor", "playbook"]
    },
    {
        "id": "ai_agents",
        "name": "AI & Agent Systems",
        "keywords": ["gemini", "ai-sdk", "agent", "llm", "live-api", "omni", "prompt", "inference", "eval", "gateway", "bot"]
    },
    {
        "id": "web_fullstack",
        "name": "Web & Full-Stack Development",
        "keywords": ["vercel", "netlify", "next.js", "react", "api-builder", "docker", "server", "backend", "frontend", "supabase", "database", "sql", "route", "cdn"]
    },
    {
        "id": "mobile_multiplatform",
        "name": "Mobile & Multiplatform",
        "keywords": ["flutter", "dart", "android", "compose", "xcode", "ios", "widget", "mobile"]
    },
    {
        "id": "cloud_data",
        "name": "Cloud Infrastructure & Big Data",
        "keywords": ["gcloud", "google-cloud", "bigquery", "bigtable", "dataproc", "composer", "airflow", "spark", "dbt", "dataform", "gcs", "lakehouse"]
    },
    {
        "id": "design_creative",
        "name": "Design & Creative Tools",
        "keywords": ["figma", "shader", "canvas", "design-system", "banner", "ui-ux", "slide", "brand", "visual"]
    },
    {
        "id": "testing_security",
        "name": "Testing, Quality & Security",
        "keywords": ["test", "audit", "security", "auth-security", "quality", "review", "memory-leak", "cookie", "a11y", "lcp", "performance", "verification"]
    },
    {
        "id": "productivity_workspace",
        "name": "Productivity & Google Workspace",
        "keywords": ["gdrive", "gsheets", "gdocs", "gslides", "workspace", "workflow", "automation"]
    },
    {
        "id": "core_system",
        "name": "Core Platform & System",
        "keywords": ["grilling", "antigravity", "agy", "skill-librarian", "plugin", "customization"]
    }
]

def classify_skill(skill_id: str, name: str, description: str, plugin_name: str) -> Tuple[str, str, List[str]]:
    """Determine category_id, category_name, and tags for a skill."""
    text_to_search = f"{skill_id} {name} {description} {plugin_name}".lower()
    
    # Priority checks
    if skill_id in ["grilling", "antigravity-guide", "agy-customizations", "skill-librarian", "plugin", "run-workflow"]:
        return "core_system", "Core Platform & System", ["core", "system"]

    scores = {}
    for cat in CATEGORIES:
        score = 0
        for kw in cat["keywords"]:
            if kw in text_to_search:
                score += 2 if kw in skill_id or kw in plugin_name else 1
        scores[cat["id"]] = score

    best_cat_id = max(scores, key=scores.get)
    if scores[best_cat_id] == 0:
        best_cat_id = "web_fullstack"  # Default fallback

    best_cat = next(c for c in CATEGORIES if c["id"] == best_cat_id)
    
    # Extract tags
    tags = set()
    tags.add(best_cat["id"])
    if plugin_name:
        tags.add(plugin_name)
    for kw in best_cat["keywords"]:
        if kw in text_to_search:
            tags.add(kw)

    return best_cat["id"], best_cat["name"], sorted(list(tags))
