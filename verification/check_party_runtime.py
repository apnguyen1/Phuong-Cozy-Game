"""Validate recorded eight-client evidence; this command does not run Roblox.

Run 02 remains aborted/false. Only its seven completed, independently reviewed
scenarios are credited, before the exact known optional-input wrapper failure.
Run 03 retains its failed airborne waypoint; only its earlier automatic-arrival
and camera observations are credited. Run 04 must pass grounded circulation.
Use --complete-run for a current-source party run. A separately bound
--camera-run may demonstrate desktop rotation while preserving the party run's
specific unsupported mouse-input observations; it never rewrites them as pass.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "roblox/evidence/draft02"
HELPERS = ("roblox/tests/party-runtime.server.luau", "roblox/tests/party-runtime.client.luau")
PRODUCTION = ("roblox/birthday-lobby.server.luau", "roblox/birthday-lobby.client.luau",
              "roblox/build-bedroom02.luau", "roblox/Phuong-Cozy-World-Draft02.rbxl")
PARTY_CHECKS = {
    "eight-distinct-players-and-spawn-slots", "eight-lobby-seats-simultaneously-occupied",
    "early-prompt-enters-before-own-deadline",
    "early-entry-leaves-seven-deadlines-hud-and-cameras-independent",
    "deadline-adjacent-prompt-burst-enters-once", "party-test-keeps-full-sixty-second-deadline",
    "eight-courtyard-seats-simultaneously-occupied",
}
DEFAULT_OWNER_CHECKS = {
    "eight-distinct-players-and-spawn-slots",
    "eight-default-ownership-clients-see-safe-world-arrival",
    "six-visitors-enter-and-circulate-at-normal-speed", "six-visitors-exit-bedroom-without-traps",
}
CIRCULATION_CHECKS = (DEFAULT_OWNER_CHECKS - {"eight-default-ownership-clients-see-safe-world-arrival"}
                      | {"eight-simultaneous-pad-entries-complete"})
KNOWN_ABORT = (
    "ServerScriptService.Draft02PartyServer:39: VirtualInput::SendMouseDelta: cursor is not locked.\n"
    "ServerScriptService.Draft02PartyServer:39 function client\n"
    "ServerScriptService.Draft02PartyServer:143\n"
    "ServerScriptService.Draft02PartyServer:85\n"
)


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def normalize(value):
    """Only contiguous Luau numeric-key arrays change representation, never values."""
    if isinstance(value, list):
        return [normalize(item) for item in value]
    if isinstance(value, dict):
        if value and all(key.isdigit() for key in value) and sorted(map(int, value)) == list(range(1, len(value)+1)):
            return [normalize(value[str(i)]) for i in range(1, len(value)+1)]
        return {key: normalize(item) for key, item in value.items()}
    return value


def number(value):
    return type(value) in (int, float) and math.isfinite(value)


def vector(value):
    require(isinstance(value, list) and len(value) == 3 and all(number(n) for n in value), "Invalid position/look vector")
    return value


def distance(a, b):
    return math.dist(vector(a), vector(b))


def keyed(items, key, count=None):
    require(isinstance(items, list), f"Missing {key} list")
    result = {}
    for item in items:
        require(isinstance(item, dict) and key in item and item[key] not in result, f"Missing/duplicate {key}")
        result[item[key]] = item
    require(count is None or len(result) == count, f"Expected {count} distinct {key} entries")
    return result


def load_run(run):
    return load_bound_run(run, "party", HELPERS, PRODUCTION)


def load_camera_run(run):
    return load_bound_run(run, "camera", ("roblox/tests/camera-runtime.server.luau", HELPERS[1]),
                          tuple(name for name in PRODUCTION if name != "roblox/build-bedroom02.luau"))


def load_bound_run(run, prefix, helpers, production):
    require(re.fullmatch(r"[0-9]{2}", run), "Run identifier must be two digits")
    raw = read(EVIDENCE / f"{prefix}-runtime{run}-raw.json")
    require(raw.get("isError") is not True, "Tool-level engine error")
    texts = [item["text"] for item in raw.get("content", []) if item.get("type") == "text"]
    require(len(texts) == 1, "Expected one actual engine result text")
    result = normalize(json.loads(texts[0]))
    bindings = read(EVIDENCE / f"{prefix}-source-bindings{run}.json")
    require(isinstance(bindings.get("captured_before_test_at_utc"), str), "Missing prelaunch binding time")
    files = bindings.get("files", {})
    archive_path = EVIDENCE / f"{prefix}-harness{run}-sources.json"
    archive = read(archive_path) if archive_path.is_file() else None
    for name in helpers + production:
        expected = files.get(name)
        require(isinstance(expected, str) and re.fullmatch(r"[0-9a-fA-F]{64}", expected), f"Missing binding: {name}")
        if name in helpers and archive is not None:
            require(isinstance(archive.get(name), str), f"Missing archived helper: {name}")
            data = archive[name].encode("utf-8")
        else:
            data = (ROOT / name).read_bytes()
        require(hashlib.sha256(data).hexdigest() == expected.lower(), f"Source/checkpoint binding changed: run {run}: {name}")
    return result, files


def common(result, expected, failed=()):
    require(result.get("schema_version") == 1 and result.get("test") == "Draft02Party"
            and result.get("engine") == "Studio actual eight-client multiplayer", "Wrong actual engine identity")
    checks = keyed(result.get("checks"), "name")
    require(set(checks) == expected and all(c.get("passed") is (name not in failed) for name, c in checks.items()),
            "Missing, extra, unexecuted or failed scenario")
    snaps = keyed(result.get("snapshots"), "label")
    initial = keyed(snaps["initial-eight"]["players"], "userId", 8)
    require(all(type(uid) is int for uid in initial), "Invalid actual user IDs")
    require({p.get("slot") for p in initial.values()} == set(range(8)), "Eight available spawn slots not demonstrated")
    require(all(p.get("location") == "Lobby" and p.get("health") == 100 for p in initial.values()), "Unsafe initial lobby state")
    for p in initial.values():
        vector(p.get("position"))
    events = result.get("events")
    require(isinstance(events, list) and all(number(e.get("at")) for e in events), "Missing finite event times")
    return checks, snaps, initial, events


def events_for(events, uid, kind, **fields):
    return [e for e in events if e.get("userId") == uid and e.get("kind") == kind
            and all(e.get(key) == value for key, value in fields.items())]


def world_client(state):
    require(not state.get("error") and state.get("location") == "World" and state.get("hud") is False
            and state.get("ownSubject") is True and state.get("cameraType") == "Custom"
            and state.get("health") == 100 and state.get("deadline") is None, "Client did not observe healthy world/HUD/camera state")


def verify_party(result, complete=False, camera_result=None):
    if complete:
        require(result.get("passed") is True and not result.get("error")
                and result.get("testMode") == "Draft02Party", "Complete current party run did not fully pass")
    else:
        require(result.get("passed") is False and result.get("error") == KNOWN_ABORT,
                "Partial run must retain its exact known optional-orbit abort, not an invented overall pass or unknown failure")
    expected = PARTY_CHECKS | ({"six-visitors-enter-and-circulate-at-normal-speed", "six-visitors-exit-bedroom-without-traps"} if complete else set())
    checks, snaps, initial, events = common(result, expected)
    for name, prefix in (("eight-lobby-seats-simultaneously-occupied", "Workspace.CozyWorld_Draft01.BirthdayLobby.EightGuestSeats."),
                         ("eight-courtyard-seats-simultaneously-occupied", "Workspace.CozyWorld_Draft01.SurroundingContext.NeighborhoodDetails02.BirthdayCourtyard.")):
        occupants = keyed(checks[name].get("details"), "userId", 8)
        seated = keyed(snaps[name]["players"], "userId", 8)
        require(set(occupants) == set(initial) == set(seated), "Seat occupants do not match eight actual clients")
        seats = [entry.get("seat") for entry in occupants.values()]
        require(all(isinstance(s, str) and s.startswith(prefix) for s in seats) and len(set(seats)) == 8, "Seat identities missing/shared/out of venue")
        require(all(seated[uid].get("seat") == occupants[uid]["seat"] and seated[uid].get("health") == 100 for uid in initial), "Actual seated snapshot mismatch")
    obs = result["observations"]
    before, after = keyed(obs["beforeEarly"], "userId", 8), keyed(obs["afterEarly"], "userId", 8)
    require(set(before) == set(after) == set(initial), "Early-entry client identity mismatch")
    early = checks["early-prompt-enters-before-own-deadline"]["details"]
    uid = early["input"]["after"]["userId"]
    world_client(after[uid])
    moved = events_for(events, uid, "location", location="World")
    prompts = events_for(events, uid, "engine-prompt-triggered")
    require(len(moved) == 1 and len(prompts) == 1, "Early entry needs actual unambiguous prompt and World events")
    require(moved[0]["at"] == early["enteredAt"] and prompts[0]["at"] == early["promptAt"]
            and abs(moved[0]["at"]-prompts[0]["at"]) < .5
            and early["originalDeadline"] == before[uid]["deadline"]
            and moved[0]["at"] < early["originalDeadline"]-2, "Input start alone cannot prove early World entry")
    max_look_delta = 0
    for other in set(initial)-{uid}:
        x, y = before[other], after[other]
        require(x.get("location") == y.get("location") == "Lobby" and number(x.get("deadline"))
                and x["deadline"] == y.get("deadline") and y.get("hud") is True
                and y.get("ownSubject") is True and y.get("cameraType") == "Custom"
                and y["at"] > early["enteredAt"], "Waiting client's deadline/HUD/camera changed")
        delta = distance(x["cameraLook"], y["cameraLook"])
        require(delta <= .03, "Waiting client's look changed materially")
        max_look_delta = max(max_look_delta, delta)
    race = checks["deadline-adjacent-prompt-burst-enters-once"]["details"]
    require(race["userId"] != uid and race["userId"] in initial, "Deadline case needs a separate actual client")
    moved = events_for(events, race["userId"], "location", location="World")
    prompts = events_for(events, race["userId"], "engine-prompt-triggered")
    starts = events_for(events, race["userId"], "deadline", deadline=race["deadline"])
    require(len(moved) == 1 and race["worldTransitions"] == 1 and moved[0]["at"] == race["enteredAt"], "Duplicate/missing deadline transition")
    require(any(e["at"] == race["acceptedPromptAt"] and abs(e["at"]-race["deadline"]) < .6 for e in prompts), "Timer-only entry cannot prove accepted deadline prompt")
    require(len(starts) == 1 and starts[0]["at"] == race["deadlineSetAt"]
            and abs(race["deadline"]-starts[0]["at"]-60) < .1, "Deadline was shortened or unobserved")
    require(-.5 <= race["enteredAt"]-race["deadline"] < 2, "Entry is not deadline-adjacent")
    attempts = race["attempts"]
    require(len(attempts) == 3 and attempts[0]["beganAt"] < race["deadline"] < attempts[-1]["endedAt"], "No repeated input burst across deadline")
    require(all(number(a["beganAt"]) and number(a["endedAt"]) and a["endedAt"] >= a["beganAt"]+.3 for a in attempts), "Invalid prompt hold timing")
    output = {"credited_completed_scenarios": len(expected), "engine_overall_passed": result["passed"],
            "retained_abort": result.get("error"), "early_entry_seconds_before_deadline": round(early["originalDeadline"]-early["enteredAt"], 3),
            "deadline_prompt_delta_seconds": round(race["acceptedPromptAt"]-race["deadline"], 4),
            "max_waiting_camera_look_delta": max_look_delta}
    if complete:
        output["walking"] = verify_walking(obs, initial)
        if camera_result is None:
            output["orbit"] = verify_orbits(obs, keyed(obs["beforeOrbits"], "userId", 2))
        else:
            # Only the exact observed unsupported-input case can use separate
            # camera evidence. Unknown errors or a falsely claimed pass fail.
            retained = []
            for key in ("orbitA", "orbitB"):
                observation = obs[key]
                require(observation.get("supported") is False
                        and observation.get("error") == "VirtualInput::SendMouseDelta: cursor is not locked."
                        and observation.get("inputMethod") == "Studio VirtualInput mouse delta",
                        "Unknown party orbit failure cannot be replaced by separate evidence")
                world_client(observation["before"]); world_client(observation["after"])
                require(distance(observation["before"]["cameraLook"], observation["after"]["cameraLook"]) < .03,
                        "Unsupported party orbit differs from reviewed unchanged-view observation")
                retained.append({"observation": key, "supported": False, "error": observation["error"]})
            output["retained_party_orbit_observations"] = retained
            output["separate_desktop_lobby_orbit"] = verify_focused_camera(camera_result)
            output["camera_limit"] = "Separate desktop lobby input only; the party run's post-seating mouse observations remain unsupported. No physical touch or human comfort claim."
    return output


def verify_default_arrival(result):
    require(result.get("passed") is False and not result.get("error")
            and result.get("testMode") == "Draft02PartyCirculation", "Run03 must retain its known unsuccessful circulation result")
    _, snaps, initial, events = common(result, DEFAULT_OWNER_CHECKS,
                                     failed={"six-visitors-enter-and-circulate-at-normal-speed"})
    obs = result["observations"]
    failed_paths = [p for p in obs["bedroomPaths"] if p.get("passed") is False]
    require(len(obs["bedroomPaths"]) == 6 and len(failed_paths) == 1, "Unknown run03 circulation failure pattern")
    failed_path = failed_paths[0]
    failed_step = failed_path["steps"][-1]
    require(len(failed_path["steps"]) == 4 and failed_step["distance"] < 2 and failed_step["health"] == 100
            and failed_path["after"]["health"] == 100 and failed_step["floorError"] > 3
            and abs(failed_step["finish"][1]-failed_step["target"][1]-failed_step["floorError"]) < .001,
            "Run03 failure is not the reviewed elevated final waypoint")
    clients = keyed(obs["defaultOwnershipArrival"], "userId", 8)
    server = keyed(snaps["all-eight-world-default-ownership"]["players"], "userId", 8)
    require(set(clients) == set(server) == set(initial), "Arrival is missing an actual client")
    durations = []
    for uid, state in clients.items():
        world_client(state)
        require(state.get("serverNetworkOwner") == uid, "Automatic arrival did not retain observed client network ownership")
        p = vector(state["position"])
        require(distance(p, server[uid]["position"]) < 2 and math.hypot(p[0]-25, p[2]-114) < 25
                and abs(p[1]-4) <= 3, "Client position is not replicated safe outdoor arrival")
        starts = events_for(events, uid, "deadline", deadline=initial[uid]["deadline"])
        finishes = events_for(events, uid, "location", location="World")
        require(len(starts) == len(finishes) == 1 and not events_for(events, uid, "engine-prompt-triggered"), "Expected automatic timer-only arrival")
        require(abs(starts[0]["deadline"]-starts[0]["at"]-60) < .1
                and -.05 <= finishes[0]["at"]-starts[0]["deadline"] < 2.5, "Normal-owner automatic deadline timing invalid")
        durations.append(finishes[0]["at"]-starts[0]["at"])
    return {"engine_overall_passed": False, "credited": "Eight normal-owner automatic arrivals and two independent automated desktop orbit observations only",
            "uncredited_failed_circulation": {"user_id": failed_path["userId"], "floor_error": failed_step["floorError"]},
            "automatic_timer_duration_range_seconds": [round(min(durations),3), round(max(durations),3)],
            "orbit": verify_orbits(obs, clients)}


def verify_orbits(obs, baseline, validate_state=world_client):
    orbit = []
    for key in ("orbitA", "orbitB"):
        observation = obs[key]
        require(observation.get("supported") is True and not observation.get("error")
                and observation.get("inputMethod") == "Studio VirtualInput mouse delta", "Desktop orbit observation unsupported/failed")
        before, after = observation["before"], observation["after"]
        validate_state(before); validate_state(after)
        uid = before["userId"]
        require(uid in baseline and after["userId"] == uid and after["at"] > before["at"], "Orbit client/time mismatch")
        change = distance(before["cameraLook"], after["cameraLook"])
        require(change > .2 and distance(before["position"], after["position"]) < .1, "Camera did not rotate independently of avatar movement")
        orbit.append({"user_id": uid, "look_vector_change": change})
    require(orbit[0]["user_id"] != orbit[1]["user_id"]
            and obs["orbitB"]["before"]["at"] > obs["orbitA"]["after"]["at"]
            and distance(obs["orbitB"]["before"]["cameraLook"], baseline[orbit[1]["user_id"]]["cameraLook"]) <= .03,
            "Second client's view changed before its own input")
    return orbit


def verify_focused_camera(result):
    require(result.get("test") == "Draft02Camera"
            and result.get("engine") == "Studio actual two-client multiplayer"
            and result.get("passed") is True and not result.get("error"), "Focused camera run failed or has wrong engine identity")
    obs = result["observations"]
    baseline = keyed(obs["beforeOrbits"], "userId", 2)

    def lobby_camera(state):
        require(not state.get("error") and state.get("location") == "Lobby"
                and state.get("hud") is True and state.get("ownSubject") is True
                and state.get("cameraType") == "Custom" and state.get("health") == 100
                and number(state.get("at")) and number(state.get("deadline"))
                and state["deadline"] > state["at"] and not state.get("seat"), "Focused client is not safely waiting in lobby")
        require(abs(vector(state["position"])[0]-2000) < 30, "Focused lobby position invalid")

    for state in baseline.values():
        lobby_camera(state)
    for key in ("orbitA", "orbitB"):
        observation = obs[key]
        diagnostic = observation.get("observedInput", {})
        require(diagnostic.get("touch") is False and diagnostic.get("preferred") == "KeyboardAndMouse"
                and diagnostic.get("rightButtonDown") is True
                and diagnostic.get("mouseBehavior") == "LockCurrentPosition", "Actual client desktop input/lock not demonstrated")
        before, after = observation["before"], observation["after"]
        require(before["userId"] in baseline, "Focused client missing baseline")
        start = baseline[before["userId"]]
        require(start["at"] <= before["at"] and before["deadline"] == after["deadline"] == start["deadline"]
                and distance(start["cameraLook"], before["cameraLook"]) <= .03,
                "Focused camera/deadline baseline unsettled or changed before input")
    return verify_orbits(obs, baseline, lobby_camera)


def verify_circulation(result):
    require(result.get("passed") is True and not result.get("error")
            and result.get("testMode") == "Draft02PartyPromptCirculation", "Final circulation engine run failed, aborted or has wrong mode")
    _, _, initial, events = common(result, CIRCULATION_CHECKS)
    obs = result["observations"]
    entries = obs["simultaneousPrompts"]
    require(isinstance(entries, list) and len(entries) == 8, "Missing concurrent prompt clients")
    clients = keyed([e["after"] for e in entries], "userId", 8)
    inputs = {e["after"]["userId"]: e["attempts"][0] for e in entries}
    require(set(clients) == set(initial), "Concurrent entry client identities differ")
    prompt_times = []
    hold_intervals = []
    for entry in entries:
        attempt = entry["attempts"][0]
        require(number(attempt["beganAt"]) and number(attempt["endedAt"])
                and attempt["endedAt"] >= attempt["beganAt"]+.3, "Concurrent prompt hold interval missing")
        hold_intervals.append((attempt["beganAt"], attempt["endedAt"]))
    for uid, state in clients.items():
        world_client(state)
        moved = events_for(events, uid, "location", location="World")
        prompts = events_for(events, uid, "engine-prompt-triggered")
        require(len(moved) == 1 and len(prompts) == 1
                and abs(moved[0]["at"]-prompts[0]["at"]) < .5
                and moved[0]["at"] < initial[uid]["deadline"]-2, "Concurrent entry needs one actual early engine prompt/World event per player")
        require(inputs[uid]["beganAt"] <= prompts[0]["at"] <= inputs[uid]["endedAt"]+.1,
                "Accepted prompt does not correspond to its recorded input interval")
        prompt_times.append(prompts[0]["at"])
    peak_holds = max(sum(begin <= at < end for begin, end in hold_intervals) for at, _ in hold_intervals)
    require(peak_holds >= 2, "No overlapping actual prompt holds; sequential entries do not demonstrate concurrent input")
    return {"credited_completed_scenarios": 4, "engine_overall_passed": True,
            "actual_clients": 8, **verify_walking(obs, initial),
            "concurrent_prompt_spread_seconds": round(max(prompt_times)-min(prompt_times),3),
            "peak_overlapping_prompt_holds": peak_holds,
            "limits": "Programmatic holds and MoveTo are engine tests. Physical touch/manual orbit, device performance, same-user reconnect and human acceptance are not supplied by this validator."}


def verify_walking(obs, initial):
    identities = None
    max_floor = 0
    for field, targets in (("bedroomPaths", [[-1,4,-122],[-1,4,-131],[-1,4,-144]]),
                           ("bedroomExits", [[1,4,-139],[-1,4,-129],[-1,4,-120]])):
        paths = keyed(obs[field], "userId", 6)
        require(set(paths).issubset(initial) and (identities is None or set(paths) == identities), "Walking guests differ or are missing")
        identities = set(paths)
        for uid, path in paths.items():
            require(path.get("passed") is True and not path.get("error") and path["after"]["health"] == 100, "Guest failed actual circulation")
            steps = path["steps"]
            require(len(steps) == 4 and [s["target"] for s in steps[:3]] == targets, "Required door/interior route omitted")
            require(number(path["startedAt"]) and path["finishedAt"] > path["startedAt"], "Walking time missing")
            last = path["startedAt"]
            for step in steps:
                finish, target = vector(step["finish"]), vector(step["target"])
                horizontal = math.hypot(finish[0]-target[0], finish[2]-target[2])
                floor_error = abs(finish[1]-target[1])
                require(horizontal < 2 and abs(horizontal-step["distance"]) < .001
                        and floor_error <= 3 and abs(floor_error-step["floorError"]) < .001
                        and isinstance(step.get("floorMaterial"), str) and step["floorMaterial"] != "Air"
                        and step["health"] == 100 and step["at"] > last, "Invalid/falling/incomplete physical waypoint")
                max_floor = max(max_floor, floor_error)
                last = step["at"]
            require(distance(path["after"]["position"], steps[-1]["finish"]) < 2, "Final walking observation disagrees")
            last_target = steps[-1]["target"]
            if field == "bedroomPaths":
                require(5 <= last_target[0] <= 13 and -151 <= last_target[2] <= -146, "Final route is not inside bedroom")
            else:
                require(last_target[2] == -112, "Exit does not reach porch")
    return {"actual_walking_guests": 6, "maximum_waypoint_floor_error": max_floor}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--circulation-run", default="04")
    parser.add_argument("--complete-run", help="Prefer a fully passing current-source Draft02Party run instead of historical composite evidence")
    parser.add_argument("--camera-run", help="Separately bound current-source desktop lobby observation; preserves unsupported party mouse observations")
    args = parser.parse_args()
    try:
        if args.complete_run:
            result, party_bindings = load_run(args.complete_run)
            camera_result = None
            if args.camera_run:
                camera_result, camera_bindings = load_camera_run(args.camera_run)
                require(all(party_bindings[name] == camera_bindings[name] for name in PRODUCTION
                            if name != "roblox/build-bedroom02.luau"), "Party/camera production revisions differ")
            print(json.dumps({"status": "PASS", "mode": "Validate existing real engine evidence; does not rerun Roblox",
                              "complete_run": args.complete_run, "camera_run": args.camera_run,
                              "party": verify_party(result, complete=True, camera_result=camera_result)}, indent=2))
            return 0
        require(args.camera_run is None, "A separate camera run requires complete party evidence")
        party, party_bindings = load_run("02")
        normal_arrival, normal_bindings = load_run("03")
        circulation, circulation_bindings = load_run(args.circulation_run)
        require(all(party_bindings[name] == normal_bindings[name] == circulation_bindings[name] for name in PRODUCTION), "Runs exercised different production/checkpoint revisions")
        print(json.dumps({"status": "PASS", "mode": "Validate existing real engine evidence; does not rerun Roblox",
                          "party_run02": verify_party(party), "default_ownership_run03": verify_default_arrival(normal_arrival),
                          "circulation_run": args.circulation_run,
                          "circulation": verify_circulation(circulation)}, indent=2))
    except (OSError, ValueError, TypeError, KeyError, AttributeError) as error:
        print(json.dumps({"status": "FAIL", "detail": str(error)}))
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
