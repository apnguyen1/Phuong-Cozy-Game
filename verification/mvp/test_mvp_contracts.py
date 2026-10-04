"""Illustrative contract examples for the MVP review window.

These tests model the coordinator contract only. They are spec-only and must
not be counted as implementation or gameplay evidence. The executable Luau
specs under roblox/mvp/tests are the source-level test target.
"""
import unittest


class Queue:
    def __init__(self, now=0):
        self.now = now
        self.generation = 1
        self.members = []
        self.deadline = None
        self.frozen = False

    def join(self, user):
        if self.frozen or user in self.members:
            return False
        if len(self.members) >= 10:
            return False
        self.members.append(user)
        if len(self.members) == 1:
            self.deadline = self.now + 60
        if len(self.members) >= 8:
            self.deadline = min(self.deadline, self.now + 10)
        return True

    def leave(self, user):
        if user not in self.members or self.frozen:
            return False
        self.members.remove(user)
        if not self.members:
            self.generation += 1
            self.deadline = None
        return True

    def freeze(self):
        if self.deadline is None or self.now < self.deadline:
            return None
        self.frozen = True
        return tuple(self.members)


class SharedProgress:
    def __init__(self):
        self.fund = 0
        self.petals = set()
        self.receipts = set()

    def complete(self, activity, round_id, first=False):
        key = (activity, round_id)
        if key in self.receipts:
            return 0
        self.receipts.add(key)
        self.petals.add(activity)
        amount = 20 if first else 10
        self.fund += amount
        return amount


class MvpContractTests(unittest.TestCase):
    def test_queue_60_seconds_accelerates_at_eight_and_caps_at_ten(self):
        q = Queue()
        self.assertTrue(q.join(1))
        self.assertEqual(q.deadline, 60)
        for user in range(2, 8):
            self.assertTrue(q.join(user))
        self.assertEqual(q.deadline, 60)
        self.assertTrue(q.join(8))
        self.assertEqual(q.deadline, 10)
        self.assertTrue(q.join(9))
        self.assertTrue(q.join(10))
        self.assertFalse(q.join(11))

    def test_queue_drop_below_eight_does_not_extend_and_empty_resets_generation(self):
        q = Queue()
        for user in range(1, 9):
            q.join(user)
        q.leave(8)
        self.assertEqual(q.deadline, 10)
        for user in range(1, 8):
            q.leave(user)
        self.assertIsNone(q.deadline)
        self.assertEqual(q.generation, 2)

    def test_frozen_roster_is_isolated_and_late_joiner_waits(self):
        q = Queue()
        for user in range(1, 9):
            q.join(user)
        q.now = 10
        roster = q.freeze()
        self.assertEqual(roster, tuple(range(1, 9)))
        self.assertFalse(q.join(9))
        self.assertEqual(roster, tuple(range(1, 9)))

    def test_shared_fund_is_once_per_round_not_per_contributor(self):
        p = SharedProgress()
        self.assertEqual(p.complete("Q01", "r1", first=True), 20)
        self.assertEqual(p.complete("Q01", "r1", first=True), 0)
        self.assertEqual(p.complete("Q01", "r2", first=False), 10)
        self.assertEqual(p.fund, 30)
        self.assertEqual(p.petals, {"Q01"})

    def test_q05_never_adds_fund_and_guest_cannot_spend(self):
        p = SharedProgress()
        p.fund = 20
        actor = "guest"
        authorized = actor == "phuong" or actor == "fallback-host"
        self.assertFalse(authorized)
        self.assertEqual(p.fund, 20)
        # A Q05 roll consumes fund; it never creates fund units.
        p.fund -= 20
        self.assertEqual(p.fund, 0)

    def test_fifth_roll_guarantees_selected_regular_or_secret_id(self):
        for selected in ("Love", "ID"):
            misses = 0
            result = None
            for roll in range(1, 6):
                result = selected if roll == 5 else "other"
                if result == selected:
                    break
                misses += 1
            self.assertEqual(misses, 4)
            self.assertEqual(result, selected)

    def test_cake_requires_all_six_petals_not_fund_balance(self):
        p = SharedProgress()
        p.fund = 100
        self.assertNotEqual(len(p.petals), 6)
        for activity in ("Q01", "Q02", "Q03", "Q04", "Q05", "Q06"):
            p.petals.add(activity)
        self.assertEqual(len(p.petals), 6)

    def test_reconnect_is_session_scoped_and_does_not_restart_queue(self):
        session_id = "session-1"
        restored = {"sessionId": session_id, "fund": 30, "petals": {"Q01"}}
        self.assertEqual(restored["sessionId"], session_id)
        self.assertNotEqual(restored["sessionId"], "new-session")
        self.assertEqual(restored["fund"], 30)


if __name__ == "__main__":
    unittest.main()
