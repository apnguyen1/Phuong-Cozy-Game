"""Ticket verification and evidence gates. Python 3.11+, Pillow for raster checks."""

from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import importlib.metadata
import json
from pathlib import Path
import re
import subprocess
import sys
import uuid


TOKENS = {"forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink"}
HEX = re.compile(r"^#[0-9a-fA-F]{6}$")
IDENTIFIER = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_-]*$")
SKIP = {".git", "node_modules", "__pycache__", ".venv-verification"}
COMMON_GATES = [
    {"id": "ticket-match", "reviewer": "independent", "prompt": "All ticket requirements and submitted source files are covered; the assigned object/activity was built, with no substituted scope."},
    {"id": "shared-scope", "reviewer": "independent", "prompt": "Preserve touch/desktop access, independent third-person cameras, real group participation, one detailed bedroom, six quests and the empty user-authored note. No invented rooms, economy, forced cinematic or guest messages. Verify dependency interfaces and that automated tests exercise the actual ticket behavior."},
    {"id": "visual-identity", "reviewer": "independent", "prompt": "Compare reference and actual result. Required silhouette, proportions, named features and color placement survive simplification; readability is clear at play scale."},
    {"id": "roblox-import", "reviewer": "independent", "prompt": "Import this exact revision in Roblox Studio. Record place/model identity, scale, pivot, orientation, materials/textures, collision and console results; test it in context."},
    {"id": "final-acceptance", "reviewer": "human", "prompt": "The user has reviewed this exact revision and explicitly accepted it as finished. Preserve their actual decision and comments."},
]
GAME_GATES = [
    {"id": "playability", "reviewer": "independent", "prompt": "In Studio Play, demonstrate start, intended actions, feedback, forgiving mistakes, completion and exit on the target controls. Inspect client/server errors."},
    {"id": "replay", "reviewer": "independent", "prompt": "Test cancellation/re-entry, three repeated plays, leaving/returning and reconnect. No stuck controls, duplicate callbacks/rewards or lost committed session progress. Test cross-session saves only when PCW-13 defines them; do not invent persistence guarantees."},
    {"id": "mixed-device", "reviewer": "independent", "prompt": "Complete the changed flow via touch on phone/tablet and via desktop controls. Record named devices, readable text, unobstructed move/jump/orbit zones, close/cancel and busy/error states."},
    {"id": "shared-session", "reviewer": "independent", "prompt": "Use at least two clients: simultaneous actions, competing slot, disconnect, reservation release, late join and one reward only. Cameras stay independent; Phuong finishing permissions hold. For PCW-16 rehearse with 8-10 participants on named devices."},
    {"id": "fun", "reviewer": "human", "prompt": "User playtest: was the goal clear, did choices/actions feel satisfying, was pacing comfortable, and would you replay? Record duration, enjoyable moment, friction and requested change. User decides whether it is good enough."},
]


class Invalid(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise Invalid(message)


def nonempty(value):
    return isinstance(value, str) and bool(value.strip())


def read_json(path):
    with path.open(encoding="utf-8-sig") as handle:
        return json.load(handle)


def sha(path):
    with path.open("rb") as handle:
        return hashlib.file_digest(handle, "sha256").hexdigest()


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def local(root, name):
    require(nonempty(name), "Paths must be nonempty strings")
    require(not Path(name).is_absolute(), f"Use a project-relative path: {name}")
    result = (root / name).resolve()
    require(result.is_relative_to(root), f"Path escapes project: {name}")
    return result


def relative(root, path):
    return path.resolve().relative_to(root).as_posix()


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("x", encoding="utf-8") as handle:
        json.dump(value, handle, indent=2, ensure_ascii=False)
        handle.write("\n")


def source_criteria(root, ticket_id):
    """Load the real ticket each time so a manifest cannot quietly omit an AC."""
    source = f"docs/tickets/{ticket_id}.md"
    content = local(root, source).read_text(encoding="utf-8-sig")
    sections = {}
    for heading in ("Purpose", "Deliverable", "Acceptance criteria", "Limits and open decisions", "Validation"):
        match = re.search(r"^## " + re.escape(heading) + r"\s*\n(.*?)(?=^## |\Z)", content, re.M | re.S)
        require(match and match.group(1).strip(), f"{source}: missing {heading}")
        sections[heading] = match.group(1).strip()
    acceptance = [line[2:].strip() for line in sections["Acceptance criteria"].splitlines() if line.startswith("- ")]
    require(acceptance, f"{source}: acceptance criteria must contain bullets")
    gates = [{"id": f"{ticket_id}-AC{index:02}", "reviewer": "independent", "prompt": value} for index, value in enumerate(acceptance, 1)]
    gates.append({"id": f"{ticket_id}-scope", "reviewer": "independent", "prompt": "Deliverable: " + sections["Deliverable"] + "\nLimits/open decisions: " + sections["Limits and open decisions"] + "\nValidation: " + sections["Validation"]})
    return source, content.splitlines()[0].lstrip("# "), sections["Purpose"], gates


def load_ticket(root, name):
    ticket = read_json(local(root, name))
    require(isinstance(ticket, dict) and ticket.get("schema_version") == 1, "Ticket schema_version must be 1")
    require(isinstance(ticket.get("id"), str) and IDENTIFIER.fullmatch(ticket["id"]), "Invalid ticket id")
    require(ticket.get("kind") in {"game", "image", "model", "document"}, "Ticket kind must be game, image, model or document")
    require(ticket.get("stage") in {"concept", "production"}, "Ticket stage must be concept or production")
    require(ticket.get("target") == "roblox", "This harness targets Roblox")
    require(ticket.get("status") in {"draft", "approved"}, "Ticket status must be draft or approved")
    require(nonempty(ticket.get("intent")) and nonempty(ticket.get("title")), "Ticket needs a title and concrete intent")
    for field in ("sources", "inputs", "artifacts"):
        require(isinstance(ticket.get(field), list) and ticket[field], f"Ticket needs nonempty {field}")
    require(isinstance(ticket.get("criteria"), list), "criteria must be an array of additional review checks")
    source, _, _, inherited = source_criteria(root, ticket["id"])
    require(source in ticket["sources"], f"sources must include {source}")
    ticket["source_criteria"] = inherited
    for name in ticket["sources"] + ticket["inputs"]:
        local(root, name)
    require(type(ticket.get("max_iterations")) is int and 1 <= ticket["max_iterations"] <= 20, "max_iterations must be 1..20")
    ids = set()
    for artifact in ticket["artifacts"]:
        require(isinstance(artifact, dict), "Artifact must be an object")
        require(nonempty(artifact.get("id")) and artifact["id"] not in ids, "Artifact ids must be unique")
        ids.add(artifact["id"])
        local(root, artifact.get("path"))
        require(artifact.get("check") in {"exists", "raster_palette", "studio_palette"}, "Unsupported artifact check")
        if artifact["check"] != "exists":
            allowed = artifact.get("allowed_tokens")
            needed = artifact.get("required_tokens", [])
            require(isinstance(allowed, list) and allowed and all(isinstance(t, str) and t in TOKENS for t in allowed), "Invalid allowed_tokens")
            require(isinstance(needed, list) and all(t in allowed for t in needed), "required_tokens must be allowed")
    commands = ticket.get("commands")
    require(isinstance(commands, list), "commands must be a list (empty is allowed for art)")
    ids = set()
    for command in commands:
        require(isinstance(command, dict), "Command must be an object")
        require(isinstance(command.get("id"), str) and IDENTIFIER.fullmatch(command["id"]) and command["id"] not in ids, "Command ids must be unique identifiers")
        ids.add(command["id"])
        require(isinstance(command.get("argv"), list) and command["argv"] and all(nonempty(arg) for arg in command["argv"]), "Command argv must be a nonempty string array")
        local(root, command.get("cwd", "."))
        require(type(command.get("timeout_seconds")) is int and 1 <= command["timeout_seconds"] <= 600, "Command timeout_seconds must be 1..600")
    ids = {gate["id"] for gate in gates_for(ticket, custom=False)}
    for criterion in ticket["criteria"]:
        require(isinstance(criterion, dict), "Criterion must be an object")
        require(nonempty(criterion.get("id")) and criterion["id"] not in ids, "Criterion ids must be unique and cannot replace built-in gates")
        ids.add(criterion["id"])
        require(criterion.get("reviewer") in {"human", "independent"} and nonempty(criterion.get("prompt")), "Criterion needs reviewer and prompt")
    return ticket


def gates_for(ticket, custom=True):
    common = list(COMMON_GATES)
    if ticket["stage"] == "concept" or ticket["kind"] == "document":
        common = [gate for gate in common if gate["id"] != "roblox-import"]
        common.append({"id": "roblox-handoff", "reviewer": "independent", "prompt": "This concept/specification preserves Roblox/mobile/group constraints and explicitly records pending import/playtests. Approval here does not mean production-ready or playable."})
    return common + (GAME_GATES if ticket["kind"] == "game" and ticket["stage"] == "production" else []) + ticket["source_criteria"] + (ticket["criteria"] if custom else [])


def snapshot(root, ticket_name, ticket, changes=None):
    paths = [ticket_name, "verification/palette.json", "verification/verify.py", "verification/requirements.txt", "verification/roblox/capture.luau"]
    paths += ticket["sources"] + ticket["inputs"] + [a["path"] for a in ticket["artifacts"]]
    if changes:
        paths.append(changes)
    result = {}
    for name in paths:
        path = local(root, name)
        require(not path.is_relative_to(root / "verification/runs"), "Inputs must stay outside verification/runs; copy evidence there separately")
        if path.is_dir():
            require(not (root / "verification/runs").is_relative_to(path), "Track specific source folders, not the repository root or verification folder")
            result[relative(root, path) + "/"] = "directory"
            for item in sorted(path.rglob("*")):
                if any(part in SKIP for part in item.relative_to(path).parts):
                    continue
                require(item.resolve().is_relative_to(root), f"Input symlink escapes project: {item}")
                if item.is_file():
                    result[relative(root, item)] = sha(item)
        else:
            result[relative(root, path)] = sha(path) if path.is_file() else None
    try:
        pillow = importlib.metadata.version("Pillow")
    except importlib.metadata.PackageNotFoundError:
        pillow = "missing"
    result["@runtime"] = {"python": sys.version, "Pillow": pillow}
    return result


def palette_values(root):
    palette = read_json(root / "verification/palette.json")
    require(palette.get("schema_version") == 1, "Palette schema_version must be 1")
    require(palette.get("status") == "approved" and nonempty(palette.get("approved_by")), "Palette has not been approved; supply the assigned color codes")
    colors = palette.get("colors")
    require(isinstance(colors, dict) and set(colors) == TOKENS, "Palette must define exactly the eight assigned tokens")
    require(all(isinstance(v, str) and HEX.fullmatch(v) for v in colors.values()), "Every palette token needs an exact #RRGGBB value")
    return {token: value.upper() for token, value in colors.items()}


def raster_check(path, artifact, colors):
    from PIL import Image, ImageSequence

    allowed = {colors[t] for t in artifact["allowed_tokens"]}
    counts = Counter()
    with Image.open(path) as source:
        # Check every animation frame; fully transparent pixels have no visible color.
        for frame in ImageSequence.Iterator(source):
            rgba = frame.convert("RGBA")
            for count, pixel in rgba.getcolors(rgba.width * rgba.height) or []:
                if pixel[3] > 0:
                    counts["#%02X%02X%02X" % pixel[:3]] += count
    require(counts, "Image has no visible pixels")
    wrong = {color: count for color, count in counts.items() if color not in allowed}
    require(not wrong, f"Off-palette visible pixels (including translucent edges): {dict(Counter(wrong).most_common(12))}")
    missing = [token for token in artifact.get("required_tokens", []) if colors[token] not in counts]
    require(not missing, f"Required colors absent: {missing}")
    return {"visible_pixels": sum(counts.values()), "colors": dict(counts)}


def studio_check(path, artifact, colors, ticket):
    data = read_json(path)
    require(data.get("schema_version") == 1 and data.get("ticket_id") == ticket["id"], "Studio capture has the wrong schema or ticket id")
    require(nonempty(data.get("root")) and nonempty(data.get("captured_at")), "Studio capture needs root and capture time")
    parts = data.get("parts")
    require(isinstance(parts, list) and parts, "Studio capture must contain parts")
    paths, seen = set(), set()
    for part in parts:
        require(isinstance(part, dict) and nonempty(part.get("path")) and part["path"] not in paths, "Invalid or duplicate Studio part path")
        paths.add(part["path"])
        token = part.get("token")
        require(isinstance(token, str) and token in artifact["allowed_tokens"], f"{part['path']}: assign a valid PaletteToken attribute")
        actual = part.get("hex")
        require(isinstance(actual, str) and actual.upper() == colors[token], f"{part['path']}: {token} expected {colors[token]}, got {actual}")
        seen.add(token)
    missing = set(artifact.get("required_tokens", [])) - seen
    require(not missing, f"Required material tokens absent: {sorted(missing)}")
    textures = data.get("textures")
    require(isinstance(textures, list), "Studio capture needs a textures list, even when empty")
    mappings = artifact.get("texture_sources", {})
    require(isinstance(mappings, dict), "texture_sources must map Roblox content IDs to raster artifact IDs")
    raster_ids = {a["id"] for a in ticket["artifacts"] if a["check"] == "raster_palette"}
    for texture in textures:
        content_id = texture.get("content_id")
        require(nonempty(content_id) and mappings.get(content_id) in raster_ids, f"Texture {content_id}: map its actual source to a raster_palette artifact in texture_sources")
    return {"parts": len(parts), "tokens": sorted(seen), "note": "Authored BasePart colors only. Capture provenance, textures, GUI and actual import require independent review."}


def check_result(check_id, status, detail):
    return {"id": check_id, "status": status, "detail": detail}


def run_checks(root, ticket, execute, folder):
    results = []
    approved = ticket["status"] == "approved" and nonempty(ticket.get("approved_by"))
    results.append(check_result("ticket-approved", "PASS" if approved else "BLOCKED", "Approved ticket required; a draft is not an assignment"))
    colors = None
    try:
        colors = palette_values(root)
        results.append(check_result("palette", "PASS", colors))
    except (OSError, ValueError, AttributeError) as error:
        results.append(check_result("palette", "BLOCKED", str(error)))
    for name in ticket["sources"] + ticket["inputs"]:
        path = local(root, name)
        exists = path.exists() and (path.is_dir() or path.stat().st_size > 0)
        results.append(check_result(f"input:{name}", "PASS" if exists else "BLOCKED", "Required input exists" if exists else "Required source/input is missing or empty"))
    palette_checks = {a["check"] for a in ticket["artifacts"]}
    required_check = "raster_palette" if ticket["kind"] == "image" else "studio_palette"
    if ticket["kind"] != "document" and required_check not in palette_checks:
        results.append(check_result("palette-coverage", "BLOCKED", f"This ticket needs a {required_check} artifact"))
    if ticket["kind"] == "game" and ticket["stage"] == "production" and not ticket["commands"]:
        results.append(check_result("game-tests", "BLOCKED", "Add a real behavior test command for the game's completion/replay/progression rules"))
    for artifact in ticket["artifacts"]:
        path = local(root, artifact["path"])
        check_id = f"artifact:{artifact['id']}"
        if not path.is_file() or path.stat().st_size == 0:
            results.append(check_result(check_id, "BLOCKED", f"Missing or empty artifact: {artifact['path']}"))
            continue
        if artifact["check"] != "exists" and colors is None:
            results.append(check_result(check_id, "BLOCKED", "Exact palette values are unresolved"))
            continue
        try:
            if artifact["check"] == "raster_palette":
                detail = raster_check(path, artifact, colors)
            elif artifact["check"] == "studio_palette":
                detail = studio_check(path, artifact, colors, ticket)
            else:
                detail = "File present; format/import correctness is an independent review gate"
            results.append(check_result(check_id, "PASS", detail))
        except ImportError:
            results.append(check_result(check_id, "BLOCKED", "Install verification/requirements.txt for raster inspection"))
        except (OSError, ValueError, TypeError, KeyError, AttributeError) as error:
            results.append(check_result(check_id, "FAIL", str(error)))
    for command in ticket["commands"]:
        check_id = f"test:{command['id']}"
        if not execute or not approved:
            results.append(check_result(check_id, "BLOCKED", "Review the approved ticket's argv, then run with --execute-checks"))
            continue
        argv = [sys.executable if arg == "{python}" else arg for arg in command["argv"]]
        log = folder / f"{command['id']}.log"
        try:
            with log.open("wb") as output:
                completed = subprocess.run(argv, cwd=local(root, command.get("cwd", ".")), stdout=output, stderr=subprocess.STDOUT, timeout=command["timeout_seconds"], shell=False)
            results.append(check_result(check_id, "PASS" if completed.returncode == 0 else "FAIL", {"exit_code": completed.returncode, "log": relative(root, log), "sha256": sha(log)}))
        except subprocess.TimeoutExpired:
            results.append(check_result(check_id, "FAIL", f"Timed out after {command['timeout_seconds']} seconds; see {relative(root, log)}"))
        except OSError as error:
            results.append(check_result(check_id, "BLOCKED", f"Could not execute test: {error}"))
    return results


def status_for(checks, success):
    if any(check["status"] == "FAIL" for check in checks):
        return "CHANGES_REQUIRED"
    if any(check["status"] != "PASS" for check in checks):
        return "BLOCKED"
    return success


def render_report(report):
    lines = [f"# {report['ticket_id']} — {report['status']}", "", f"Stage: {report['stage']} · Iteration {report['iteration']} · {report['run_id']}", "", "## Automatic checks", ""]
    for check in report["checks"]:
        lines.append(f"- **{check['status']}** `{check['id']}`: {check['detail']}")
    lines += ["", "## Required review", ""]
    for gate in report["gates"]:
        lines.append(f"- `{gate['id']}` ({gate['reviewer']}): {gate['prompt']}")
    lines += ["", "Fix failed checks, gather missing evidence, then create a new iteration. READY_FOR_REVIEW is not final acceptance.", ""]
    return "\n".join(lines)


def run(root, args):
    ticket = load_ticket(root, args.ticket)
    require(nonempty(args.builder), "Builder identity is required")
    iteration = 1
    previous = None
    if args.previous:
        previous_path = local(root, args.previous)
        previous = read_json(previous_path)
        require(previous.get("ticket_id") == ticket["id"] and previous.get("type") == "run", "Previous report must be a run for this ticket")
        iteration = previous["iteration"] + 1
        require(args.changes and local(root, args.changes).is_file() and local(root, args.changes).stat().st_size > 0, "A linked iteration needs --changes with fixes and regression notes")
    require(iteration <= ticket["max_iterations"], "NEEDS_DECISION: iteration budget reached; user must decide next scope/budget")
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "-" + uuid.uuid4().hex[:8]
    folder = root / "verification/runs" / ticket["id"] / run_id
    folder.mkdir(parents=True)
    before = snapshot(root, args.ticket, ticket, args.changes)
    checks = run_checks(root, ticket, args.execute_checks, folder)
    after = snapshot(root, args.ticket, ticket, args.changes)
    if before != after:
        checks.append(check_result("stable-inputs", "FAIL", "Tracked files changed while checking. Finish builds first and rerun on stable artifacts."))
    report = {"schema_version": 1, "type": "run", "ticket_id": ticket["id"], "ticket_path": args.ticket, "run_id": run_id,
              "stage": ticket["stage"], "iteration": iteration, "builder": args.builder, "previous": {"path": args.previous, "sha256": sha(local(root, args.previous))} if previous else None,
              "changes": args.changes, "snapshot": before, "fingerprint": digest(before), "checks": checks,
              "gates": gates_for(ticket), "status": status_for(checks, "READY_FOR_REVIEW")}
    report_path = folder / "report.json"
    write_json(report_path, report)
    (folder / "report.md").write_text(render_report(report), encoding="utf-8")
    print(f"{report['status']}: {relative(root, report_path)}")
    return 0 if report["status"] == "READY_FOR_REVIEW" else 1


def review_template(root, args):
    path = local(root, args.report)
    report = read_json(path)
    require(report.get("type") == "run", "Expected a run report")
    require(args.reviewer.strip().casefold() != report["builder"].strip().casefold(), "Builder cannot independently review their own submission")
    review = {"schema_version": 1, "run_id": report["run_id"], "report_sha256": sha(path), "reviewer": args.reviewer,
              "reviewer_type": args.reviewer_type,
              "decisions": [{"criterion": gate["id"], "verdict": "pending", "notes": "", "evidence": []} for gate in report["gates"] if args.reviewer_type == "human" or gate["reviewer"] != "human"]}
    write_json(local(root, args.out), review)
    print(f"Review template: {args.out}")
    return 0


def finalize(root, args):
    report_path = local(root, args.report)
    report = read_json(report_path)
    require(report.get("type") == "run" and report.get("schema_version") == 1, "Expected a run report")
    ticket = load_ticket(root, report["ticket_path"])
    checks = list(report["checks"])
    current = snapshot(root, report["ticket_path"], ticket, report["changes"])
    require(current == report["snapshot"] and digest(current) == report["fingerprint"], "Stale report: ticket, palette, sources, artifacts or verifier changed; run a new iteration")
    require(report["gates"] == gates_for(ticket), "Report review gates do not match the current ticket")
    require(checks and report["status"] == status_for(checks, "READY_FOR_REVIEW"), "Report status is inconsistent")
    for check in checks:
        detail = check["detail"]
        if isinstance(detail, dict) and "log" in detail:
            require(sha(local(root, detail["log"])) == detail["sha256"], "Test evidence changed; run checks again")
    decisions = {gate["id"]: [] for gate in report["gates"]}
    reviews = []
    for name in args.review:
        path = local(root, name)
        review = read_json(path)
        require(review.get("schema_version") == 1 and review.get("run_id") == report["run_id"] and review.get("report_sha256") == sha(report_path), "Review belongs to a different or modified report")
        require(nonempty(review.get("reviewer")) and review["reviewer"].strip().casefold() != report["builder"].strip().casefold(), "Builder cannot approve their own submission")
        require(review.get("reviewer_type") in {"human", "agent"}, "reviewer_type must be human or agent")
        require(isinstance(review.get("decisions"), list), "Review decisions must be an array")
        seen = set()
        evidence_hashes = {}
        for decision in review["decisions"]:
            criterion = decision.get("criterion")
            require(criterion in decisions and criterion not in seen, "Unknown or duplicate review criterion")
            seen.add(criterion)
            require(decision.get("verdict") in {"pass", "fail", "pending"}, "Invalid review verdict")
            if decision["verdict"] == "pending":
                continue
            require(nonempty(decision.get("notes")), f"{criterion}: describe what was actually observed")
            evidence = decision.get("evidence")
            require(isinstance(evidence, list) and evidence, f"{criterion}: evidence files are required")
            for item in evidence:
                evidence_path = local(root, item)
                require(evidence_path.is_file() and evidence_path.stat().st_size > 0, f"Missing evidence: {item}")
                evidence_hashes[item] = sha(evidence_path)
            decisions[criterion].append({**decision, "reviewer": review["reviewer"], "reviewer_type": review["reviewer_type"]})
        reviews.append({"path": name, "sha256": sha(path), "evidence": evidence_hashes})
    for gate in report["gates"]:
        entries = decisions[gate["id"]]
        accepted = [entry for entry in entries if gate["reviewer"] != "human" or entry["reviewer_type"] == "human"]
        # A failure cannot be overwritten by a second review claiming pass.
        state = "FAIL" if any(entry["verdict"] == "fail" for entry in entries) else "PASS" if any(entry["verdict"] == "pass" for entry in accepted) else "BLOCKED"
        checks.append(check_result(f"review:{gate['id']}", state, entries or "Missing review and evidence"))
    result = {"schema_version": 1, "type": "decision", "ticket_id": report["ticket_id"], "stage": report["stage"], "run_id": report["run_id"],
              "report": {"path": args.report, "sha256": sha(report_path)}, "fingerprint": report["fingerprint"], "reviews": reviews,
              "status": status_for(checks, "PASS"), "checks": checks}
    output_path = local(root, args.out)
    require(output_path.suffix == ".json", "Final decision output must end in .json")
    markdown_path = output_path.with_suffix(".md")
    require(not markdown_path.exists(), f"Output already exists: {markdown_path}")
    write_json(output_path, result)
    markdown = [f"# {result['ticket_id']} — {result['status']}", "", f"Stage: {result['stage']} · Run: {result['run_id']}", ""]
    for check in checks:
        if check["status"] != "PASS":
            markdown.append(f"- **{check['status']}** `{check['id']}`: {check['detail']}")
    if result["status"] == "PASS":
        markdown.append("All required checks and reviews passed for this exact revision and stage.")
    markdown_path.write_text("\n".join(markdown) + "\n", encoding="utf-8")
    print(f"{result['status']}: {args.out}")
    return 0 if result["status"] == "PASS" else 1


def scaffold(root, args):
    require(IDENTIFIER.fullmatch(args.ticket_id), "Invalid ticket id")
    source, title, intent, _ = source_criteria(root, args.ticket_id)
    base = f"deliverables/{args.ticket_id}"
    artifact = {"id": "deliverable", "path": base + "/deliverable.md", "check": "exists"}
    artifacts = [artifact]
    if args.kind == "image":
        artifact["path"] = base + "/image.png"
        if args.stage == "production":
            artifact.update({"check": "raster_palette", "allowed_tokens": sorted(TOKENS), "required_tokens": []})
        else:
            artifacts.append({"id": "source-colors", "path": base + "/source-colors.png", "check": "raster_palette", "allowed_tokens": sorted(TOKENS), "required_tokens": []})
    elif args.kind in {"model", "game"}:
        artifact["path"] = base + "/model.rbxm" if args.kind == "model" else base + "/game.rbxl"
        artifacts.append({"id": "studio-colors", "path": base + "/studio-colors.json", "check": "studio_palette", "allowed_tokens": sorted(TOKENS), "required_tokens": [], "texture_sources": {}})
    contract = {"schema_version": 1, "id": args.ticket_id, "title": title, "intent": intent, "kind": args.kind, "stage": args.stage,
                "target": "roblox", "status": "draft", "approved_by": None, "max_iterations": 3,
                "sources": [source, "docs/tickets/README.md", "docs/design/map-proposal-v0.2.md", "docs/design/visual-direction-v0.1.md"],
                "inputs": [base], "artifacts": artifacts, "commands": [], "criteria": []}
    write_json(local(root, args.out), contract)
    print(f"Draft contract: {args.out}. Assign real files, tests and scope before marking approved.")
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    sub = parser.add_subparsers(dest="action", required=True)
    starter = sub.add_parser("scaffold", help="Make a draft contract from an existing Markdown ticket")
    starter.add_argument("ticket_id")
    starter.add_argument("--kind", choices=["game", "image", "model", "document"], required=True)
    starter.add_argument("--stage", choices=["concept", "production"], required=True)
    starter.add_argument("--out", required=True)
    runner = sub.add_parser("run", help="Check a stable submitted ticket revision")
    runner.add_argument("ticket")
    runner.add_argument("--builder", required=True)
    runner.add_argument("--execute-checks", action="store_true")
    runner.add_argument("--previous")
    runner.add_argument("--changes")
    reviewer = sub.add_parser("review", help="Create an unapproved evidence/review form")
    reviewer.add_argument("report")
    reviewer.add_argument("--reviewer", required=True)
    reviewer.add_argument("--reviewer-type", choices=["human", "agent"], required=True)
    reviewer.add_argument("--out", required=True)
    finalizer = sub.add_parser("finalize", help="Combine objective checks and independent/human decisions")
    finalizer.add_argument("report")
    finalizer.add_argument("--review", action="append", default=[])
    finalizer.add_argument("--out", required=True)
    args = parser.parse_args(argv)
    try:
        return {"scaffold": scaffold, "run": run, "review": review_template, "finalize": finalize}[args.action](args.root.resolve(), args)
    except (OSError, ValueError, KeyError, TypeError, AttributeError) as error:
        print(f"BLOCKED: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
