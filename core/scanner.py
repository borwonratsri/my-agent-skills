"""Scanner for locating, parsing, and indexing skills across directories."""
import os
import re
import hashlib
from pathlib import Path
from typing import Dict, List, Any, Optional
from core.taxonomy import classify_skill

def parse_frontmatter(content: str) -> Dict[str, Any]:
    """Parse YAML frontmatter between --- markers without external dependencies."""
    meta = {}
    content = content.lstrip()
    if not content.startswith("---"):
        return meta

    parts = content.split("---", 2)
    if len(parts) < 3:
        return meta

    frontmatter_text = parts[1]
    
    # Simple YAML key-value parser supporting multi-line strings
    current_key = None
    multiline_buf = []

    for line in frontmatter_text.splitlines():
        line_clean = line.strip()
        if not line_clean or line_clean.startswith("#"):
            continue
        
        match = re.match(r"^([a-zA-Z0-9_\-]+)\s*:\s*(.*)$", line)
        if match:
            if current_key and multiline_buf:
                meta[current_key] = "\n".join(multiline_buf).strip().strip("\"'")
                multiline_buf = []

            key, val = match.groups()
            current_key = key.strip()
            val = val.strip().strip("\"'")
            if val in (">", "|", ""):
                multiline_buf = []
            else:
                meta[current_key] = val
        elif current_key:
            multiline_buf.append(line_clean)

    if current_key and multiline_buf:
        meta[current_key] = "\n".join(multiline_buf).strip().strip("\"'")

    return meta

def resolve_root_path(raw_path: str) -> Optional[Path]:
    """Resolve paths with cross-platform and environment fallbacks."""
    expanded = os.path.expandvars(os.path.expanduser(raw_path))
    p = Path(expanded)
    if p.exists():
        return p

    # Fallback for Windows paths running on Linux/macOS
    if "C:/Users/" in raw_path or "C:\\Users\\" in raw_path:
        home_gemini = Path.home() / ".gemini"
        match = re.search(r'\.gemini[/\\](.*)$', raw_path)
        if match:
            candidate = home_gemini / match.group(1).replace("\\", "/")
            if candidate.exists():
                return candidate
        if home_gemini.exists():
            return home_gemini

    # Fallback to repo skills
    repo_skills = Path(__file__).parent.parent / "skills"
    if raw_path in ("skills", "./skills", "repo_skills") and repo_skills.exists():
        return repo_skills

    return None

def scan_skills(roots_config: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Scan all configured roots for SKILL.md and SKILL.md.disabled files."""
    skills = []
    seen_paths = set()

    for root_entry in roots_config:
        root_path = resolve_root_path(root_entry["path"])
        root_type = root_entry["name"]
        is_plugin = root_entry.get("is_plugin", False)

        if not root_path or not root_path.exists():
            continue

        for item in root_path.rglob("*"):
            if not item.is_file():
                continue
            
            filename = item.name.lower()
            if filename not in ("skill.md", "skill.md.disabled"):
                continue

            normalized_path = str(item.resolve())
            if normalized_path in seen_paths:
                continue
            seen_paths.add(normalized_path)

            status = "active" if filename == "skill.md" else "disabled"
            
            # Determine plugin name if within plugin root
            plugin_name = ""
            if is_plugin:
                try:
                    rel_parts = item.relative_to(root_path).parts
                    if rel_parts:
                        plugin_name = rel_parts[0]
                except ValueError:
                    pass

            # Read content
            try:
                content = item.read_text(encoding="utf-8", errors="replace")
            except Exception as e:
                continue

            content_hash = hashlib.sha256(content.encode("utf-8")).hexdigest()[:12]
            meta = parse_frontmatter(content)
            
            # Derive skill ID
            skill_id = meta.get("name")
            if not skill_id:
                # Fallback to directory name or parent directory
                skill_id = item.parent.name
                if skill_id.lower() == "skills":
                    skill_id = plugin_name or item.parent.parent.name

            skill_id = skill_id.strip()
            title = meta.get("name", skill_id)
            description = meta.get("description", "").strip()

            # If description is empty, take first paragraph after frontmatter
            if not description and len(content.split("---", 2)) >= 3:
                body = content.split("---", 2)[2].strip()
                paragraphs = [p.strip() for p in body.split("\n\n") if p.strip() and not p.strip().startswith("#")]
                if paragraphs:
                    description = paragraphs[0].replace("\n", " ")[:250]

            cat_id, cat_name, tags = classify_skill(skill_id, title, description, plugin_name)

            skills.append({
                "id": skill_id,
                "name": title,
                "description": description,
                "status": status,
                "category_id": cat_id,
                "category_name": cat_name,
                "tags": tags,
                "source_type": root_type,
                "plugin_name": plugin_name,
                "file_path": normalized_path,
                "dir_path": str(item.parent.resolve()),
                "hash": content_hash
            })

    # Sort deterministically by category then id
    skills.sort(key=lambda s: (s["category_name"], s["id"]))
    return skills
