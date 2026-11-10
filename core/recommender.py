"""
Intelligent Skill & Stack Recommender.
Analyzes user project ideas (in Thai or English) and recommends the best Preset,
critical Skills to use, and Droid configuration.
"""
import re
from typing import Dict, List, Any

KEYWORDS_MAP = {
    "web-fullstack": [
        "เว็บ", "web", "website", "frontend", "backend", "next", "react", "vue", "node",
        "api", "rest", "database", "supabase", "postgres", "sql", "login", "auth", "oauth",
        "ขายของ", "e-commerce", "ตะกร้า", "payment", "stripe", "tailwind", "css", "docker"
    ],
    "mobile-app": [
        "แอพ", "แอป", "mobile", "app", "ios", "android", "flutter", "dart", "xcode",
        "มือถือ", "notification", "กล้อง", "widget", "compose"
    ],
    "data-cloud": [
        "ข้อมูล", "data", "bigquery", "gcp", "google cloud", "pipeline", "etl", "dbt",
        "dataform", "airflow", "composer", "spark", "วิเคราะห์", "dashboard", "storage", "gcs"
    ],
    "ai-engineer": [
        "ai", "agent", "bot", "แชทบอท", "chatbot", "llm", "gemini", "claude", "openai",
        "rag", "prompt", "live api", "voice", "vision", "automation"
    ],
    "design-creative": [
        "ดีไซน์", "design", "figma", "ui", "ux", "หน้าตา", "สไลด์", "slide", "presentation",
        "แบนเนอร์", "banner", "graphics", "shader"
    ],
    "pstack-rigor": [
        "rigor", "pstack", "poteto", "mission-critical", "production-grade",
        "refactor ใหญ่", "large refactor", "zero bug", "ข้ามคืน", "overnight",
        "benchmark", "forensic", "root cause", "repro", "พิสูจน์", "architect",
        "arena", "interrogate", "deslop", "unslop"
    ]
}

INTENT_MAP = [
    {
        "keywords": ["ขายของ", "ซื้อของ", "store", "ecommerce", "e-commerce", "จ่ายเงิน", "payment", "stripe", "ตะกร้า", "cart"],
        "skills": ["marketplace", "api-builder", "auth-security-guard", "db-schema-planner"]
    },
    {
        "keywords": ["ล็อกอิน", "login", "สมัครสมาชิก", "auth", "เข้าสู่ระบบ", "ผู้ใช้", "user"],
        "skills": ["auth-security-guard", "auth", "firebase-auth-basics"]
    },
    {
        "keywords": ["หน้าตา", "ดีไซน์", "สวย", "ui", "ux", "เว็บ", "web", "react", "next", "frontend"],
        "skills": ["ui-component-builder", "ui-styling", "ui-ux-pro-max", "react-best-practices"]
    },
    {
        "keywords": ["ฐานข้อมูล", "database", "เก็บข้อมูล", "db", "sql", "ตาราง", "postgres", "supabase"],
        "skills": ["db-schema-planner", "supabase", "netlify-database"]
    },
    {
        "keywords": ["แอพ", "แอป", "มือถือ", "mobile", "flutter", "android", "ios"],
        "skills": ["flutter-apply-architecture-best-practices", "flutter-build-responsive-layout", "android-cli"]
    },
    {
        "keywords": ["กราฟ", "chart", "สถิติ", "รายงาน", "dashboard"],
        "skills": ["slides", "ui-ux-pro-max", "bigquery-sql"]
    },
    {
        "keywords": ["แชท", "บอท", "ai", "agent", "ผู้ช่วย", "llm", "gemini"],
        "skills": ["gemini-api-dev", "build-agents", "chat-sdk", "ai-sdk"]
    },
    {
        "keywords": ["เทส", "test", "testing", "unit test", "ตรวจ"],
        "skills": ["automated-testing", "tdd", "code-quality-auditor"]
    },
    {
        "keywords": ["rigor", "pstack", "poteto", "mission-critical", "เสถียรภาพสูง", "วิศวกรรม", "production-grade"],
        "skills": ["poteto-mode", "architect", "interrogate", "benchmark-checklist"]
    },
    {
        "keywords": ["refactor", "รีแฟกเตอร์", "ปรับโครงสร้าง", "แก้บั๊กยาก", "root cause", "overnight", "ข้ามคืน", "ไม่หยุด", "repro"],
        "skills": ["poteto-mode", "tdd", "no-comments", "unslop"]
    }
]

def recommend_skills_for_idea(idea_text: str, all_skills: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Analyze an idea and return recommended preset, skills, and rationale."""
    text_lower = idea_text.lower()

    # 1. Score Presets
    preset_scores = {p: 0 for p in KEYWORDS_MAP}
    for preset, kws in KEYWORDS_MAP.items():
        for kw in kws:
            if kw in text_lower:
                preset_scores[preset] += 1

    best_preset = max(preset_scores, key=preset_scores.get)
    if preset_scores[best_preset] == 0:
        best_preset = "web-fullstack"

    # 2. Score & Pick Skills
    skill_lookup = {s["id"]: s for s in all_skills}
    matched_skill_ids = []

    for group in INTENT_MAP:
        if any(kw in text_lower for kw in group["keywords"]):
            for sid in group["skills"]:
                if sid in skill_lookup and sid not in matched_skill_ids:
                    matched_skill_ids.append(sid)

    # General fallback if list is small: find by preset
    if len(matched_skill_ids) < 4:
        for sid, s in skill_lookup.items():
            if s["status"] == "active" and sid not in matched_skill_ids:
                if best_preset == "web-fullstack" and any(k in sid for k in ["ui", "api", "auth", "db"]):
                    matched_skill_ids.append(sid)
                elif best_preset == "mobile-app" and any(k in sid for k in ["flutter", "android", "dart"]):
                    matched_skill_ids.append(sid)
                elif best_preset == "ai-engineer" and any(k in sid for k in ["gemini", "agent", "ai"]):
                    matched_skill_ids.append(sid)
                elif best_preset == "pstack-rigor" and any(k in sid for k in ["poteto", "architect", "arena", "tdd", "interrogate"]):
                    matched_skill_ids.append(sid)

    recommended_skills = []
    for sid in matched_skill_ids[:6]:
        s = skill_lookup[sid]
        recommended_skills.append({
            "id": s["id"],
            "name": s["name"],
            "category": s["category_name"],
            "description": s["description"],
            "status": s["status"]
        })

    return {
        "idea": idea_text,
        "recommended_preset": best_preset,
        "preset_scores": preset_scores,
        "skills": recommended_skills
    }
