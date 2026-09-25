"""Behavior tests for approval boundaries; fixtures are never production approvals."""

import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest

from PIL import Image

import verify


PALETTE = {
    "forest": "#365744", "sage": "#A8B995", "cream": "#F5F0E4", "wood": "#95674B",
    "blossom": "#E8B7C6", "brick": "#B66C68", "golden": "#E8C779", "ink": "#26382E",
}


class VerificationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.put("verification/palette.json", {"schema_version": 1, "status": "approved", "approved_by": "fixture", "colors": PALETTE})
        self.put("verification/verify.py", "fixture verifier")
        self.put("verification/requirements.txt", "fixture requirements")
        self.put("verification/roblox/capture.luau", "fixture collector")
        self.put("docs/tickets/PCW-07.md", "# PCW-07 fixture\n\n## Purpose\nTest a bed.\n\n## Deliverable\nBed and controls.\n\n## Acceptance criteria\n- One petal only.\n- Touch works.\n\n## Limits and open decisions\nNo punishment.\n\n## Validation\nReplay and cancel.\n")
        self.put("src/state.txt", "initial version")
        self.put("evidence/playtest.txt", "FIXTURE ONLY: steps, expected and observed results")
        self.make_image("assets/bed.png", [PALETTE["sage"]])
        self.ticket = {"schema_version": 1, "id": "PCW-07", "title": "Test bed", "intent": "Make a bed", "kind": "image", "stage": "production", "target": "roblox",
                       "status": "approved", "approved_by": "fixture", "max_iterations": 3,
                       "sources": ["docs/tickets/PCW-07.md"], "inputs": ["src"],
                       "artifacts": [{"id": "bed", "path": "assets/bed.png", "check": "raster_palette", "allowed_tokens": ["sage"], "required_tokens": ["sage"]}],
                       "commands": [], "criteria": []}
        self.save_ticket()

    def put(self, name, value):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value) if not isinstance(value, str) else value, encoding="utf-8")

    def make_image(self, name, colors):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        image = Image.new("RGBA", (len(colors), 1))
        for index, color in enumerate(colors):
            image.putpixel((index, 0), tuple(bytes.fromhex(color.lstrip("#"))) + (255,))
        image.save(path)

    def save_ticket(self):
        self.put("verification/ticket.json", self.ticket)

    def call(self, *args):
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            return verify.main(["--root", str(self.root), *args])

    def run_ticket(self, *args):
        old = set(self.root.glob("verification/runs/*/*/report.json"))
        code = self.call("run", "verification/ticket.json", "--builder", "builder-1", *args)
        created = set(self.root.glob("verification/runs/*/*/report.json")) - old
        path = created.pop() if created else None
        return code, path, verify.read_json(path) if path else None

    def review(self, report, reviewer_type="human", reviewer="reviewer-1", verdict="pass", name="review.json"):
        report_name = report.relative_to(self.root).as_posix()
        code = self.call("review", report_name, "--reviewer", reviewer, "--reviewer-type", reviewer_type, "--out", name)
        if code:
            return code
        record = verify.read_json(self.root / name)
        for decision in record["decisions"]:
            decision.update(verdict=verdict, notes="Observed fixture behavior matches expected result", evidence=["evidence/playtest.txt"])
        self.put(name, record)
        return code

    def finalize(self, report, *reviews, out="decision.json"):
        args = ["finalize", report.relative_to(self.root).as_posix(), "--out", out]
        for review in reviews:
            args += ["--review", review]
        return self.call(*args)

    def test_green_run_is_not_final_approval(self):
        code, path, report = self.run_ticket()
        self.assertEqual((code, report["status"]), (0, "READY_FOR_REVIEW"))
        self.assertEqual(self.finalize(path), 1)
        self.assertEqual(verify.read_json(self.root / "decision.json")["status"], "BLOCKED")

    def test_exact_palette_with_human_evidence_passes(self):
        _, path, _ = self.run_ticket()
        self.assertEqual(self.review(path), 0)
        self.assertEqual(self.finalize(path, "review.json"), 0)

    def test_wrong_color_is_a_failure_including_latest_brick(self):
        self.ticket["artifacts"][0].update(allowed_tokens=["brick"], required_tokens=["brick"])
        self.save_ticket()
        self.make_image("assets/bed.png", ["#B77C68"])
        _, _, report = self.run_ticket()
        self.assertEqual(report["status"], "CHANGES_REQUIRED")
        self.assertIn("#B77C68", str(report["checks"]))

    def test_transparent_pixels_ignored_but_translucent_wrong_color_fails(self):
        image = Image.new("RGBA", (2, 1), (255, 0, 0, 0))
        image.putpixel((0, 0), (168, 185, 149, 255))
        image.save(self.root / "assets/bed.png")
        self.assertEqual(self.run_ticket()[2]["status"], "READY_FOR_REVIEW")
        image.putpixel((1, 0), (255, 0, 0, 1))
        image.save(self.root / "assets/bed.png")
        self.assertEqual(self.run_ticket()[2]["status"], "CHANGES_REQUIRED")

    def test_blank_image_and_missing_required_color_fail(self):
        Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(self.root / "assets/bed.png")
        self.assertEqual(self.run_ticket()[2]["status"], "CHANGES_REQUIRED")
        self.make_image("assets/bed.png", [PALETTE["cream"]])
        self.ticket["artifacts"][0]["allowed_tokens"].append("cream")
        self.save_ticket()
        self.assertEqual(self.run_ticket()[2]["status"], "CHANGES_REQUIRED")

    def test_animation_checks_later_frames(self):
        good = Image.new("RGB", (1, 1), PALETTE["sage"])
        bad = Image.new("RGB", (1, 1), "red")
        good.save(self.root / "assets/bed.gif", save_all=True, append_images=[bad], duration=100)
        self.ticket["artifacts"][0]["path"] = "assets/bed.gif"
        self.save_ticket()
        self.assertEqual(self.run_ticket()[2]["status"], "CHANGES_REQUIRED")

    def test_unknown_palette_and_missing_artifact_block(self):
        self.put("verification/palette.json", {"schema_version": 1, "status": "pending", "colors": {}})
        (self.root / "assets/bed.png").unlink()
        self.assertEqual(self.run_ticket()[2]["status"], "BLOCKED")

    def test_draft_does_not_execute_commands(self):
        self.ticket["status"] = "draft"
        self.ticket["commands"] = [{"id": "touch", "argv": ["{python}", "-c", "open('unexpected.txt','w').write('bad')"], "timeout_seconds": 10}]
        self.save_ticket()
        self.run_ticket("--execute-checks")
        self.assertFalse((self.root / "unexpected.txt").exists())

    def test_builder_cannot_review_their_submission(self):
        _, path, _ = self.run_ticket()
        self.assertEqual(self.review(path, reviewer=" BUILDER-1 "), 2)

    def test_agent_cannot_supply_final_human_approval(self):
        _, path, _ = self.run_ticket()
        self.review(path, reviewer_type="agent")
        record = verify.read_json(self.root / "review.json")
        record["decisions"].append({"criterion": "final-acceptance", "verdict": "pass", "notes": "Agent says yes", "evidence": ["evidence/playtest.txt"]})
        self.put("review.json", record)
        self.assertEqual(self.finalize(path, "review.json"), 1)

    def test_review_requires_actual_evidence(self):
        _, path, _ = self.run_ticket()
        self.review(path)
        record = verify.read_json(self.root / "review.json")
        record["decisions"][0]["evidence"] = ["missing.png"]
        self.put("review.json", record)
        self.assertEqual(self.finalize(path, "review.json"), 2)

    def test_changed_or_added_source_invalidates_review(self):
        _, path, _ = self.run_ticket()
        self.review(path)
        self.put("src/new-rule.txt", "new behavior")
        self.assertEqual(self.finalize(path, "review.json"), 2)

    def test_changed_palette_invalidates_review(self):
        _, path, _ = self.run_ticket()
        self.review(path)
        palette = verify.read_json(self.root / "verification/palette.json")
        palette["colors"]["sage"] = "#000000"
        self.put("verification/palette.json", palette)
        self.assertEqual(self.finalize(path, "review.json"), 2)

    def test_wrong_run_review_is_rejected(self):
        _, first, _ = self.run_ticket()
        self.review(first)
        _, second, _ = self.run_ticket()
        self.assertEqual(self.finalize(second, "review.json"), 2)

    def test_one_failure_cannot_be_overridden_by_another_pass(self):
        _, path, _ = self.run_ticket()
        self.review(path, verdict="fail", name="bad.json")
        self.review(path, reviewer="reviewer-2", name="good.json")
        self.assertEqual(self.finalize(path, "bad.json", "good.json"), 1)
        self.assertEqual(verify.read_json(self.root / "decision.json")["status"], "CHANGES_REQUIRED")

    def test_real_ticket_criteria_cannot_be_omitted(self):
        _, _, report = self.run_ticket()
        prompts = {gate["prompt"] for gate in report["gates"]}
        self.assertIn("One petal only.", prompts)
        self.assertIn("Touch works.", prompts)
        self.ticket["criteria"] = [{"id": "PCW-07-AC01", "reviewer": "independent", "prompt": "Weaker check"}]
        self.save_ticket()
        self.assertEqual(self.run_ticket()[0], 2)

    def test_commands_require_execution_and_fail_when_nonzero(self):
        self.ticket["commands"] = [{"id": "rules", "argv": ["{python}", "-c", "raise SystemExit(1)"], "timeout_seconds": 10}]
        self.save_ticket()
        self.assertEqual(self.run_ticket()[2]["status"], "BLOCKED")
        self.assertEqual(self.run_ticket("--execute-checks")[2]["status"], "CHANGES_REQUIRED")

    def test_mutating_test_command_does_not_approve_changed_build(self):
        self.ticket["commands"] = [{"id": "badtest", "argv": ["{python}", "-c", "open('src/state.txt','w').write('changed')"], "timeout_seconds": 10}]
        self.save_ticket()
        _, _, report = self.run_ticket("--execute-checks")
        self.assertEqual(report["status"], "CHANGES_REQUIRED")
        self.assertIn("stable-inputs", str(report["checks"]))

    def test_timeout_and_missing_tool_do_not_pass(self):
        self.ticket["commands"] = [{"id": "timeout", "argv": ["{python}", "-c", "import time; time.sleep(5)"], "timeout_seconds": 1}]
        self.save_ticket()
        self.assertEqual(self.run_ticket("--execute-checks")[2]["status"], "CHANGES_REQUIRED")
        self.ticket["commands"][0]["argv"] = ["nonexistent-verification-program-78249"]
        self.save_ticket()
        self.assertEqual(self.run_ticket("--execute-checks")[2]["status"], "BLOCKED")

    def test_revision_link_requires_changes_and_obeys_budget(self):
        _, first, _ = self.run_ticket()
        name = first.relative_to(self.root).as_posix()
        self.assertEqual(self.run_ticket("--previous", name)[0], 2)
        self.put("revision.md", "Fixed colors; rerun replay checks.")
        _, _, report = self.run_ticket("--previous", name, "--changes", "revision.md")
        self.assertEqual(report["iteration"], 2)
        self.assertEqual(report["previous"]["sha256"], verify.sha(first))
        self.ticket["max_iterations"] = 1
        self.save_ticket()
        self.assertEqual(self.run_ticket("--previous", name, "--changes", "revision.md")[0], 2)

    def test_build_review_fix_retest_loop(self):
        self.make_image("assets/bed.png", ["#FF0000"])
        _, first, report = self.run_ticket()
        self.assertEqual(report["status"], "CHANGES_REQUIRED")
        self.make_image("assets/bed.png", [PALETTE["sage"]])
        self.put("revision.md", "Replaced wrong red with the assigned sage; check all original criteria again.")
        _, second, report = self.run_ticket("--previous", first.relative_to(self.root).as_posix(), "--changes", "revision.md")
        self.assertEqual((report["iteration"], report["status"]), (2, "READY_FOR_REVIEW"))
        self.review(second)
        self.assertEqual(self.finalize(second, "review.json"), 0)

    def test_modified_test_log_is_stale_evidence(self):
        self.ticket["commands"] = [{"id": "rules", "argv": ["{python}", "-c", "print('fixture assertion passed')"], "timeout_seconds": 10}]
        self.save_ticket()
        _, path, report = self.run_ticket("--execute-checks")
        self.review(path)
        test_check = next(check for check in report["checks"] if check["id"] == "test:rules")
        self.put(test_check["detail"]["log"], "changed log")
        self.assertEqual(self.finalize(path, "review.json"), 2)

    def test_path_escape_and_unknown_check_are_rejected(self):
        self.ticket["artifacts"][0]["path"] = "../outside.png"
        self.save_ticket()
        self.assertEqual(self.run_ticket()[0], 2)
        self.ticket["artifacts"][0].update(path="assets/bed.png", check="trust-me")
        self.save_ticket()
        self.assertEqual(self.run_ticket()[0], 2)

    def studio_fixture(self):
        self.ticket.update(kind="game", commands=[{"id": "rules", "argv": ["{python}", "-c", "assert 1 + 1 == 2"], "timeout_seconds": 10}])
        self.ticket["artifacts"] = [{"id": "studio", "path": "assets/studio.json", "check": "studio_palette", "allowed_tokens": ["sage"], "required_tokens": ["sage"]}]
        capture = {"schema_version": 1, "ticket_id": "PCW-07", "root": "Workspace.Bed", "captured_at": "fixture",
                   "parts": [{"path": "Workspace.Bed.Sheet", "token": "sage", "hex": PALETTE["sage"]}], "textures": []}
        self.put("assets/studio.json", capture)
        self.save_ticket()
        return capture

    def test_game_requires_human_fun_and_multiplayer_tests(self):
        self.studio_fixture()
        _, path, report = self.run_ticket("--execute-checks")
        self.assertEqual(report["status"], "READY_FOR_REVIEW")
        gates = {gate["id"]: gate for gate in report["gates"]}
        self.assertEqual(gates["fun"]["reviewer"], "human")
        self.assertIn("mixed-device", gates)
        self.assertIn("shared-session", gates)
        self.review(path)
        self.assertEqual(self.finalize(path, "review.json"), 0)

    def test_wrong_ticket_or_material_color_fails(self):
        capture = self.studio_fixture()
        capture["ticket_id"] = "PCW-08"
        self.put("assets/studio.json", capture)
        self.assertEqual(self.run_ticket("--execute-checks")[2]["status"], "CHANGES_REQUIRED")
        capture["ticket_id"] = "PCW-07"
        capture["parts"][0]["hex"] = PALETTE["forest"]
        self.put("assets/studio.json", capture)
        self.assertEqual(self.run_ticket("--execute-checks")[2]["status"], "CHANGES_REQUIRED")

    def test_textures_cannot_hide_behind_valid_part_tint(self):
        capture = self.studio_fixture()
        capture["textures"] = [{"content_id": "rbxassetid://123"}]
        self.put("assets/studio.json", capture)
        self.assertEqual(self.run_ticket("--execute-checks")[2]["status"], "CHANGES_REQUIRED")
        self.ticket["artifacts"][0]["texture_sources"] = {"rbxassetid://123": "texture"}
        self.ticket["artifacts"].append({"id": "texture", "path": "assets/bed.png", "check": "raster_palette", "allowed_tokens": ["sage"]})
        self.save_ticket()
        self.assertEqual(self.run_ticket("--execute-checks")[2]["status"], "READY_FOR_REVIEW")

    def test_concept_pass_does_not_imply_import_pass(self):
        self.ticket["stage"] = "concept"
        self.save_ticket()
        _, _, report = self.run_ticket()
        ids = {gate["id"] for gate in report["gates"]}
        self.assertIn("roblox-handoff", ids)
        self.assertNotIn("roblox-import", ids)
        self.assertEqual(report["stage"], "concept")

    def test_scaffold_defaults_production_image_to_actual_pixels(self):
        self.assertEqual(self.call("scaffold", "PCW-07", "--kind", "image", "--stage", "production", "--out", "draft.json"), 0)
        draft = verify.read_json(self.root / "draft.json")
        self.assertEqual(draft["status"], "draft")
        self.assertEqual(draft["artifacts"][0]["check"], "raster_palette")


if __name__ == "__main__":
    unittest.main()
