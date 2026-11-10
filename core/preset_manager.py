"""Preset management and physical toggle engine (SKILL.md <-> SKILL.md.disabled)."""
import json
import fnmatch
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple

class PresetManager:
    def __init__(self, workspace_dir: Path):
        self.workspace_dir = workspace_dir
        self.presets_file = workspace_dir / "config" / "presets.json"
        self.blacklist_file = workspace_dir / "config" / "blacklist.json"
        self.active_preset_file = workspace_dir / "config" / "active_preset.json"
        self._load_configs()

    def _load_configs(self):
        with open(self.presets_file, "r", encoding="utf-8") as f:
            presets_data = json.load(f)
            self.protected_skills = set(presets_data.get("protected_skills", []))
            self.presets = presets_data.get("presets", {})

        with open(self.blacklist_file, "r", encoding="utf-8") as f:
            bl_data = json.load(f)
            self.blacklisted_skills = set(bl_data.get("blacklisted_skills", []))
            self.blacklisted_patterns = bl_data.get("blacklisted_patterns", [])

    def get_active_preset(self) -> str:
        if self.active_preset_file.exists():
            try:
                with open(self.active_preset_file, "r", encoding="utf-8") as f:
                    return json.load(f).get("active_preset", "unknown")
            except Exception:
                pass
        return "custom"

    def set_active_preset(self, preset_name: str):
        with open(self.active_preset_file, "w", encoding="utf-8") as f:
            json.dump({"active_preset": preset_name}, f, indent=2)

    def is_blacklisted(self, skill_id: str) -> bool:
        if skill_id in self.blacklisted_skills:
            return True
        for pat in self.blacklisted_patterns:
            if fnmatch.fnmatch(skill_id, pat):
                return True
        return False

    def is_skill_matching_preset(self, skill_id: str, preset_name: str) -> bool:
        if preset_name not in self.presets:
            raise ValueError(f"Preset '{preset_name}' not found. Available: {list(self.presets.keys())}")

        # Protected skills are ALWAYS enabled
        if skill_id in self.protected_skills:
            return True

        # Blacklisted skills are ALWAYS disabled
        if self.is_blacklisted(skill_id):
            return False

        include_patterns = self.presets[preset_name].get("include_patterns", [])
        for pat in include_patterns:
            if fnmatch.fnmatch(skill_id, pat):
                return True
        return False

    def apply_preset(self, preset_name: str, skills: List[Dict[str, Any]], dry_run: bool = False) -> Dict[str, Any]:
        """Physically apply preset by renaming files."""
        if preset_name not in self.presets:
            raise ValueError(f"Preset '{preset_name}' does not exist.")

        changes = []
        enabled_count = 0
        disabled_count = 0

        for skill in skills:
            skill_id = skill["id"]
            current_file = Path(skill["file_path"])
            dir_path = current_file.parent
            is_active_now = (skill["status"] == "active")

            should_be_active = self.is_skill_matching_preset(skill_id, preset_name)

            if should_be_active:
                enabled_count += 1
                if not is_active_now:
                    target_file = dir_path / "SKILL.md"
                    if not dry_run:
                        if current_file.exists():
                            current_file.rename(target_file)
                    changes.append({"id": skill_id, "action": "ENABLED", "path": str(target_file)})
                    skill["status"] = "active"
                    skill["file_path"] = str(target_file)
            else:
                disabled_count += 1
                if is_active_now:
                    target_file = dir_path / "SKILL.md.disabled"
                    if not dry_run:
                        if current_file.exists():
                            current_file.rename(target_file)
                    changes.append({"id": skill_id, "action": "DISABLED", "path": str(target_file)})
                    skill["status"] = "disabled"
                    skill["file_path"] = str(target_file)

        if not dry_run:
            self.set_active_preset(preset_name)

        return {
            "preset": preset_name,
            "total": len(skills),
            "enabled_count": enabled_count,
            "disabled_count": disabled_count,
            "changes_count": len(changes),
            "changes": changes
        }

    def toggle_skill(self, skill_id: str, skills: List[Dict[str, Any]], target_status: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Toggle an individual skill."""
        match = next((s for s in skills if s["id"].lower() == skill_id.lower()), None)
        if not match:
            return None

        current_file = Path(match["file_path"])
        dir_path = current_file.parent
        is_active = (match["status"] == "active")

        if target_status == "active" or (target_status is None and not is_active):
            target_file = dir_path / "SKILL.md"
            if current_file.exists() and current_file != target_file:
                current_file.rename(target_file)
            match["status"] = "active"
            match["file_path"] = str(target_file)
            return {"id": match["id"], "action": "ENABLED", "path": str(target_file)}
        else:
            if match["id"] in self.protected_skills:
                raise ValueError(f"Skill '{match['id']}' is a protected core skill and cannot be disabled.")
            target_file = dir_path / "SKILL.md.disabled"
            if current_file.exists() and current_file != target_file:
                current_file.rename(target_file)
            match["status"] = "disabled"
            match["file_path"] = str(target_file)
            return {"id": match["id"], "action": "DISABLED", "path": str(target_file)}
