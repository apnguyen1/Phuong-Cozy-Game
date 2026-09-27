"""Validate captured real Studio multiplayer evidence; this does not rerun Roblox.

Expected envelope: {"engine_result": <unmodified Studio EndTest result>,
"source_bindings": {"project/relative/source": "<sha256>", ...}}.
The envelope may also carry capture metadata. Results alone do not prove visual,
touch, early-prompt or camera behavior; those remain independent review gates.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_SOURCES = (
    "roblox/birthday-lobby.server.luau",
    "roblox/birthday-lobby.client.luau",
    "roblox/tests/lobby-runtime-check.luau",
)
EXPECTED_CHECKS = (
    "initial-countdown-at-most-60",
    "two-distinct-spawn-positions",
    "lobby-is-default-spawn",
    "reset-before-entry-restarts-only-own-countdown",
    "late-join-has-own-countdown",
    "guest-can-sit-during-countdown",
    "full-timer-auto-enters-without-early-trigger",
    "seated-player-detaches-on-entry",
    "timer-does-not-pull-friends-early",
    "timer-arrives-in-outdoor-arrival",
    "reset-player-full-countdown-completes",
    "world-respawn-repeat-1",
    "world-respawn-repeat-2",
    "world-respawn-repeat-3",
    "disconnect-allows-fresh-guest",
)
EXPECTED_SNAPSHOTS = (
    "initial-two-players",
    "reset-late-join-and-seated-guest",
    "first-timer-expired-friends-still-in-lobby",
    "all-in-world-after-repeated-reset",
    "replacement-guest-independent",
)


def require(value, message):
    if not value:
        raise ValueError(message)


def number(value):
    return type(value) in (int, float) and math.isfinite(value)


def check_packet(packet):
    require(isinstance(packet, dict), "Evidence envelope must be an object")
    bindings = packet.get("source_bindings")
    require(isinstance(bindings, dict), "Missing source_bindings")
    for name in REQUIRED_SOURCES:
        expected = bindings.get(name)
        require(isinstance(expected, str) and re.fullmatch(r"[0-9a-fA-F]{64}", expected),
                f"Missing SHA256 binding for {name}")
        path = ROOT / name
        require(path.is_file(), f"Bound source missing: {name}")
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        require(actual == expected.lower(), f"Stale evidence: source changed: {name}")

    result = packet.get("engine_result")
    require(isinstance(result, dict), "Missing unmodified engine_result object")
    require(result.get("schema_version") == 1, "Unsupported engine result schema")
    require(result.get("test") == "Draft02Lobby", "Wrong engine test identity")
    require(result.get("engine") == "Studio actual multiplayer", "Not actual Studio multiplayer evidence")
    require(result.get("passed") is True and not result.get("error"),
            f"Engine test failed or incomplete: {result.get('error')}")
    checks = result.get("checks")
    require(isinstance(checks, list), "Missing engine checks")
    by_name = {}
    for item in checks:
        require(isinstance(item, dict) and isinstance(item.get("name"), str), "Invalid engine check")
        require(item["name"] not in by_name, f"Duplicate engine check: {item['name']}")
        by_name[item["name"]] = item
        require(item.get("passed") is True, f"Failed engine check: {item['name']}")
    for name in EXPECTED_CHECKS:
        require(name in by_name, f"Missing scenario: {name}")
    initial_detail = by_name["initial-countdown-at-most-60"].get("details")
    require(number(initial_detail) and 55 < initial_detail <= 60,
            "Initial observed countdown was shortened or missing")

    snapshots = result.get("snapshots")
    require(isinstance(snapshots, list), "Missing engine snapshots")
    by_label = {}
    for snap in snapshots:
        require(isinstance(snap, dict) and isinstance(snap.get("label"), str), "Invalid snapshot")
        require(snap["label"] not in by_label, f"Duplicate snapshot: {snap['label']}")
        require(number(snap.get("at")), f"Snapshot missing finite engine time: {snap['label']}")
        players = snap.get("players")
        require(isinstance(players, list), "Snapshot players must be a list")
        ids = [p.get("id") for p in players if isinstance(p, dict)]
        require(len(ids) == len(players) and all(type(i) is int for i in ids), "Invalid player IDs")
        require(len(set(ids)) == len(ids), "Duplicate player identity in snapshot")
        for p in players:
            pos = p.get("position")
            require(isinstance(pos, list) and len(pos) == 3 and all(number(v) for v in pos),
                    "Player position missing or invalid")
        slots = [p.get("slot") for p in players]
        require(all(type(slot) is int and slot >= 0 for slot in slots)
                and len(set(slots)) == len(slots), "Spawn slots are missing or shared by live players")
        by_label[snap["label"]] = snap
    for label in EXPECTED_SNAPSHOTS:
        require(label in by_label, f"Missing snapshot: {label}")
    ordered = [by_label[label] for label in EXPECTED_SNAPSHOTS]
    require(all(a["at"] < b["at"] for a, b in zip(ordered, ordered[1:])),
            "Snapshots are not in strict chronological order")

    initial, reset, expired, all_world, replacement = ordered
    require(len(initial["players"]) >= 2, "Fewer than two actual players in initial snapshot")
    initial_players = {p["id"]: p for p in initial["players"]}
    require(all(p.get("location") == "Lobby" and p.get("joined") is False
                for p in initial_players.values()), "Players did not initially occupy lobby")
    for p in initial_players.values():
        require(number(p.get("remaining")) and 0 < p["remaining"] <= 60,
                "An initial player's active countdown is missing")
    require(len(reset["players"]) >= 3, "No third actual late-joining player observed")
    reset_players = {p["id"]: p for p in reset["players"]}
    require(set(initial_players).issubset(reset_players), "Initial players missing before expiry")

    first_arrivals = [p for p in expired["players"] if p.get("location") == "World"]
    require(len(first_arrivals) == 1, "First expiry did not move exactly one player")
    arrived = first_arrivals[0]
    require(arrived["id"] in initial_players and arrived["id"] in reset_players,
            "Expired player is not an original observed player")
    before = initial_players[arrived["id"]]
    initial_deadline = initial["at"] + before["remaining"]
    events = result.get("events")
    require(isinstance(events, list), "Missing actual deadline/location event timing proof")
    starts = [event for event in events if isinstance(event, dict)
              and event.get("name") == before.get("name")
              and event.get("event") == "deadline-change"
              and number(event.get("deadline")) and number(event.get("at"))
              and abs(event["deadline"] - initial_deadline) < 0.35]
    require(len(starts) == 1, "Missing unambiguous initial deadline-change event")
    timer_started = starts[0]
    require(59.5 <= timer_started["deadline"] - timer_started["at"] <= 60.1,
            "Actual deadline event does not establish an unshortened 60-second timer")
    finishes = [event for event in events if isinstance(event, dict)
                and event.get("name") == before.get("name")
                and event.get("event") == "location-change"
                and event.get("location") == "World" and number(event.get("at"))
                and timer_started["at"] < event["at"] <= expired["at"]]
    require(len(finishes) == 1, "Missing unambiguous initial world-entry event")
    actual_timer_duration = finishes[0]["at"] - timer_started["at"]
    require(59.5 <= actual_timer_duration < 62.5,
            "Observed full timer duration is too short or materially late")
    require(-0.05 <= finishes[0]["at"] - timer_started["deadline"] < 2.5,
            "Actual location-change event did not follow the original deadline")
    before_expiry = reset_players[arrived["id"]]
    require(before_expiry.get("location") == "Lobby" and number(before_expiry.get("remaining")),
            "Expiry player was not observed waiting in lobby")
    continued_deadline = reset["at"] + before_expiry["remaining"]
    require(abs(continued_deadline - initial_deadline) < 0.35,
            "Other player's reset or late join changed the waiting player's deadline")
    elapsed = expired["at"] - initial["at"]
    require(elapsed > 0, "Expiry snapshot precedes initial observation")
    require(-0.35 <= expired["at"] - initial_deadline < 2.5,
            "Automatic entry was early or materially late relative to the initial deadline")
    require(arrived.get("joined") is True and arrived.get("remaining") is None,
            "Expired player still has lobby state/countdown")
    require(all(p.get("location") == "Lobby" and p.get("joined") is False
                for p in expired["players"] if p["id"] != arrived["id"]),
            "First expiry pulled another player into the world")
    require(len(all_world["players"]) >= 3 and all(
        p.get("location") == "World" and p.get("joined") is True and p.get("remaining") is None
        for p in all_world["players"]), "World/resets did not preserve committed entry")

    all_ids = {p["id"] for p in all_world["players"]}
    fresh = [p for p in replacement["players"] if p.get("location") == "Lobby"]
    require(len(fresh) == 1 and fresh[0].get("joined") is False
            and number(fresh[0].get("remaining")) and 0 < fresh[0]["remaining"] <= 60,
            "Disconnected slot was not replaced by one fresh lobby guest")
    require(len(replacement["players"]) >= 3, "Replacement left fewer than three test players")
    departed = [p for p in all_world["players"] if p["id"] not in {r["id"] for r in replacement["players"]}]
    if departed:
        require(len(departed) == 1 and fresh[0]["slot"] == departed[0]["slot"],
                "Replacement did not reuse the disconnected guest's released slot")
    # A platform may recycle a local simulated user ID; deadline/location prove freshness.
    world_ids = {p["id"] for p in replacement["players"] if p.get("location") == "World"}
    require(len(world_ids & all_ids) >= 2, "Fresh guest disrupted the original world players")
    return {"checked_scenarios": len(EXPECTED_CHECKS),
            "peak_actual_players": max(len(s["players"]) for s in snapshots),
            "initial_snapshot_to_expiry_seconds": round(elapsed, 3),
            "full_timer_event_duration_seconds": round(actual_timer_duration, 3),
            "expiry_delta_from_initial_deadline": round(expired["at"] - initial_deadline, 3),
            "source_bindings_verified": list(REQUIRED_SOURCES)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("evidence", nargs="?", default="roblox/evidence/draft02/runtime-results.json")
    args = parser.parse_args()
    path = (ROOT / args.evidence).resolve()
    try:
        require(path.is_relative_to(ROOT), "Evidence path must stay in the project")
        result = check_packet(json.loads(path.read_text(encoding="utf-8-sig")))
        print(json.dumps({"status": "PASS", "mode": "Validate existing real engine evidence; does not rerun Roblox",
                          "evidence": path.relative_to(ROOT).as_posix(), **result}, indent=2))
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(json.dumps({"status": "FAIL", "detail": str(error)}))
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
