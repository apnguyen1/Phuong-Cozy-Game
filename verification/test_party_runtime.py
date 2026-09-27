"""Evidence-validator regression tests using retained engine packets, not game tests."""
import copy
import json
import unittest

import check_party_runtime as gate


class PartyEvidenceGateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.records = {}
        for run in ("02", "03", "04", "05"):
            raw = gate.read(gate.EVIDENCE / f"party-runtime{run}-raw.json")
            cls.records[run] = gate.normalize(json.loads(raw["content"][0]["text"]))
        cls.camera = gate.normalize(json.loads(gate.read(gate.EVIDENCE / "camera-runtime03-raw.json")["content"][0]["text"]))

    def rejected(self, run, mutate):
        packet = copy.deepcopy(self.records[run])
        mutate(packet)
        with self.assertRaises(ValueError):
            {"02": gate.verify_party, "03": gate.verify_default_arrival, "04": gate.verify_circulation}[run](packet)

    def test_completed_scenarios_preserve_partial_failures(self):
        party = gate.verify_party(self.records["02"])
        normal = gate.verify_default_arrival(self.records["03"])
        final = gate.verify_circulation(self.records["04"])
        self.assertIs(party["engine_overall_passed"], False)
        self.assertIs(normal["engine_overall_passed"], False)
        self.assertIs(final["engine_overall_passed"], True)
        self.assertEqual(final["actual_walking_guests"], 6)

    def test_unknown_partial_abort_is_rejected(self):
        self.rejected("02", lambda p: p.update(error="Unknown runtime failure"))

    def test_rewriting_partial_run_as_pass_is_rejected(self):
        self.rejected("02", lambda p: p.update(passed=True, error=None))

    def test_partial_run_cannot_satisfy_complete_current_mode(self):
        with self.assertRaises(ValueError):
            gate.verify_party(self.records["02"], complete=True)

    def test_circulation_only_cannot_satisfy_complete_current_mode(self):
        with self.assertRaises(ValueError):
            gate.verify_party(self.records["04"], complete=True)

    def test_missing_accepted_prompt_is_rejected(self):
        self.rejected("02", lambda p: p.update(events=[e for e in p["events"] if e["kind"] != "engine-prompt-triggered"]))

    def test_waiting_deadline_change_is_rejected(self):
        self.rejected("02", lambda p: p["observations"]["afterEarly"][1].update(deadline=1))

    def test_duplicate_actual_seat_occupant_is_rejected(self):
        def mutate(p):
            seats = next(c["details"] for c in p["checks"] if c["name"] == "eight-lobby-seats-simultaneously-occupied")
            seats[1]["userId"] = seats[0]["userId"]
        self.rejected("02", mutate)

    def test_duplicate_world_transition_is_rejected(self):
        def mutate(p):
            event = next(e for e in p["events"] if e["kind"] == "location" and e.get("location") == "World")
            p["events"].append(copy.deepcopy(event))
        self.rejected("02", mutate)

    def test_client_still_in_lobby_is_rejected(self):
        self.rejected("03", lambda p: p["observations"]["defaultOwnershipArrival"][0].update(position=[2000, 4, -14]))

    def test_unknown_normal_arrival_failure_is_rejected(self):
        self.rejected("03", lambda p: p.update(error="Unexpected failure"))

    def test_no_orbit_movement_is_rejected(self):
        def mutate(p):
            orbit = p["observations"]["orbitA"]
            orbit["after"]["cameraLook"] = orbit["before"]["cameraLook"]
        self.rejected("03", mutate)

    def test_airborne_final_waypoint_is_rejected(self):
        self.rejected("04", lambda p: p["observations"]["bedroomPaths"][0]["steps"][-1].update(floorMaterial="Air"))

    def test_shortened_door_route_is_rejected(self):
        self.rejected("04", lambda p: p["observations"]["bedroomPaths"][0]["steps"].pop(0))

    def test_invented_input_times_are_rejected(self):
        def mutate(p):
            for entry in p["observations"]["simultaneousPrompts"]:
                entry["attempts"][0].update(beganAt=0, endedAt=1)
        self.rejected("04", mutate)

    def test_current_party_and_separate_desktop_preserve_unsupported_steps(self):
        result = gate.verify_party(self.records["05"], complete=True, camera_result=self.camera)
        self.assertEqual(result["credited_completed_scenarios"], 9)
        self.assertEqual(len(result["separate_desktop_lobby_orbit"]), 2)
        self.assertTrue(all(item["supported"] is False for item in result["retained_party_orbit_observations"]))

    def test_current_party_without_camera_evidence_cannot_claim_orbit(self):
        with self.assertRaises(ValueError):
            gate.verify_party(self.records["05"], complete=True)

    def test_unknown_party_orbit_error_not_hidden_by_focused_success(self):
        packet = copy.deepcopy(self.records["05"])
        packet["observations"]["orbitA"]["error"] = "Unexpected production exception"
        with self.assertRaises(ValueError):
            gate.verify_party(packet, complete=True, camera_result=self.camera)

    def test_touch_input_cannot_count_as_desktop_rotation(self):
        packet = copy.deepcopy(self.camera)
        packet["observations"]["orbitA"]["observedInput"]["touch"] = True
        with self.assertRaises(ValueError):
            gate.verify_focused_camera(packet)

    def test_second_client_changed_before_own_input_is_rejected(self):
        packet = copy.deepcopy(self.camera)
        packet["observations"]["orbitB"]["before"]["cameraLook"] = [1, 0, 0]
        with self.assertRaises(ValueError):
            gate.verify_focused_camera(packet)

    def test_focused_desktop_without_rotation_is_rejected(self):
        packet = copy.deepcopy(self.camera)
        packet["observations"]["orbitA"]["after"]["cameraLook"] = packet["observations"]["orbitA"]["before"]["cameraLook"]
        with self.assertRaises(ValueError):
            gate.verify_focused_camera(packet)


if __name__ == "__main__":
    unittest.main()
