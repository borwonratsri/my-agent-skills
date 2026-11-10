"""
Factory-style Droid (Subagent) Management and Project Scoping Engine.
Implements the Autonomous Droid Trio: Coder, Reviewer, and Tester with Tool Gating.
"""
import json
from pathlib import Path
from typing import Dict, List, Any, Optional

DEFAULT_DROID_TRIO = {
    "coder-droid": {
        "name": "Coder Droid",
        "role": "Autonomous Software Engineer",
        "description": "Implements features, fixes bugs, and performs codebase refactorings based on user requirements.",
        "permissions": {
            "can_read": True,
            "can_write": True,
            "can_run_commands": True,
            "mode": "full"
        },
        "system_prompt": (
            "You are Coder Droid, an autonomous senior software engineer. "
            "Your task is to write clean, idiomatic, and maintainable code adhering to project architecture. "
            "You have full write and terminal execution access. "
            "Always follow best practices, verify dependencies, and ensure your implementation is ready for the Test Droid."
        ),
        "recommended_skills": ["project-scaffolder", "api-builder", "ui-component-builder", "react-best-practices"]
    },
    "tester-droid": {
        "name": "Tester Droid",
        "role": "QA & Automation Engineer",
        "description": "Writes unit and integration tests, executes test suites, and verifies code correctness.",
        "permissions": {
            "can_read": True,
            "can_write": True,
            "can_run_commands": True,
            "mode": "test_only"
        },
        "system_prompt": (
            "You are Tester Droid, an expert QA and automation engineer. "
            "Your task is to verify code written by the Coder Droid by writing unit, integration, and edge-case tests. "
            "Execute the test suites and report concrete pass/fail metrics. "
            "If tests fail, diagnose the root causes and provide actionable bug reports back to Coder Droid."
        ),
        "recommended_skills": ["automated-testing", "tdd", "chrome-devtools"]
    },
    "reviewer-droid": {
        "name": "Reviewer Droid",
        "role": "Staff Engineer & Security Auditor",
        "description": "Inspects code changes for architectural adherence, security vulnerabilities, and quality standards (Read-Only).",
        "permissions": {
            "can_read": True,
            "can_write": False,
            "can_run_commands": False,
            "mode": "read_only"
        },
        "system_prompt": (
            "You are Reviewer Droid, an uncompromising staff engineer and security auditor. "
            "Your role is STRICTLY READ-ONLY: you review diffs, audit code quality, check for OWASP/security vulnerabilities, and verify spec adherence. "
            "Do not modify files. Issue clear verdicts: [APPROVED], [CHANGES_REQUESTED], or [SECURITY_RISK] with actionable feedback."
        ),
        "recommended_skills": ["code-review", "code-quality-auditor", "auth-security-guard", "firebase-security-rules-auditor"]
    }
}

class DroidManager:
    def __init__(self, workspace_root: Path):
        self.workspace_root = workspace_root
        self.catalog_file = workspace_root / "catalog.json"

    def init_project_droids(self, target_dir: Path, preset_name: str = "web-fullstack") -> Dict[str, Any]:
        """Initialize .droids/ structure in a target project."""
        target_dir = target_dir.resolve()
        droids_dir = target_dir / ".droids"
        droids_dir.mkdir(parents=True, exist_ok=True)

        # Load global catalog if available
        available_skills = []
        if self.catalog_file.exists():
            with open(self.catalog_file, "r", encoding="utf-8") as f:
                cat = json.load(f)
                available_skills = cat.get("skills", [])

        # Configure Droids tailored to preset
        droids_config = {
            "project_path": str(target_dir),
            "preset": preset_name,
            "droids": DEFAULT_DROID_TRIO,
            "pipeline": {
                "sequence": ["coder-droid", "tester-droid", "reviewer-droid"],
                "max_feedback_loops": 3,
                "auto_stop_on_approval": True
            }
        }

        # Write droids.json
        droids_json_path = droids_dir / "droids.json"
        with open(droids_json_path, "w", encoding="utf-8") as f:
            json.dump(droids_config, f, indent=2, ensure_ascii=False)

        # Write DROIDS.md documentation
        droids_md_path = droids_dir / "DROIDS.md"
        droids_md_content = self._generate_droids_md(droids_config)
        with open(droids_md_path, "w", encoding="utf-8") as f:
            f.write(droids_md_content)

        return {
            "target_dir": str(target_dir),
            "preset": preset_name,
            "droids_dir": str(droids_dir),
            "droids_count": len(DEFAULT_DROID_TRIO),
            "pipeline_sequence": droids_config["pipeline"]["sequence"]
        }

    def _generate_droids_md(self, config: Dict[str, Any]) -> str:
        lines = [
            "# 🤖 Project Droids (Factory-Style Autonomous Subagents)",
            "",
            f"**Project Preset:** `{config['preset']}`",
            "",
            "This project is configured with Factory-style autonomous subagents with tool gating and dedicated responsibilities:",
            "",
            "## 👥 The Droid Trio",
            "",
            "| Droid | Role | Permissions | Key Responsibilities |",
            "| :--- | :--- | :---: | :--- |"
        ]

        for did, d in config["droids"].items():
            perm_str = "Full (Read/Write/Exec)" if d["permissions"]["mode"] == "full" else (
                "Test Only (Write tests & Run)" if d["permissions"]["mode"] == "test_only" else "🔒 Read-Only"
            )
            lines.append(f"| **{d['name']}** (`{did}`) | {d['role']} | `{perm_str}` | {d['description']} |")

        lines.extend([
            "",
            "## 🔄 Autonomous Pipeline Workflow (Dark Factory)",
            "",
            "```mermaid",
            "flowchart LR",
            "    Task[User Task / Issue] --> Coder[Coder Droid]",
            "    Coder -->|Implementation| Tester[Tester Droid]",
            "    Tester -->|Tests Fail| Coder",
            "    Tester -->|Tests Pass| Reviewer[Reviewer Droid]",
            "    Reviewer -->|Changes Requested| Coder",
            "    Reviewer -->|APPROVED| PR[Ready for PR / Merge]",
            "```",
            "",
            "### How to Invoke in Antigravity Chat:",
            "- To run the full autonomous pipeline: Ask the agent `Run autonomous pipeline for: <task description>`",
            "- To invoke a specific Droid: Ask the agent `Invoke Reviewer Droid to audit <file>`",
            "",
            "### How to Run via CLI:",
            "```bash",
            'python "d:\\Warm Project\\SKILL library\\skill_manager.py" pipeline "Implement user authentication with JWT"',
            "```"
        ])
        return "\n".join(lines)
