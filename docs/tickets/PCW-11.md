# PCW-11 — Q05 — A Labubu Wish

**Status:** MVP implementation in progress; evidence-gated
**Dependencies:** PCW-02, PCW-04, PCW-05, PCW-06, PCW-13
**Location:** UDistrict side, outside the crossing and pedestrian route

## Purpose and deliverable

Phuong chooses a wanted Big into Energy figure at a native vending cabinet. Everyone may inspect it; only Phuong or a configured present host fallback may spend the shared birthday fund. A roll costs 20 shared-fund units and awards directly to Phuong's session-only collection before the optional reveal.

The seven logical outcomes are six regular figures at 16.5% each and secret ID at 1%. After four unsuccessful rolls for the locked wanted figure, the fifth roll guarantees that figure, including ID. An owned figure fulfills the selected wanted choice immediately. The wanted choice remains locked until fulfilled; selecting a new choice afterward resets that choice's counter. Q05 awards exactly one shared petal when Phuong receives the wanted figure and never earns fund currency.

## Acceptance criteria

- The activity exposes the common `new(ctx)`, `CreateRound`, `Apply`, and `GetView` server adapter contract.
- Inspection is available concurrently to all participants without reserving the cabinet.
- Ordinary guests cannot select a target or spend; Phuong or configured present host fallback can do so.
- Debit and figure award are atomic through `SessionService:CommitPurchase`; no debit occurs without an award.
- Repeated action IDs return the prior receipt without a second debit, award, counter change, or petal.
- All seven outcomes are supported; regular weights are 16.5% each and ID is 1% outside the guarantee override.
- The fifth unsuccessful roll awards the wanted figure, including when the wanted figure is ID.
- The reveal is optional/skippable and cannot lose an already committed award after close, leave, or disconnect.
- Phuong's session collection, shared fund, wanted counter, and one Q05 petal restore on same-session rejoin and reset for a new session.
- Touch and desktop UI can render the returned inspect/select/roll/busy/awarded/insufficient states without blocking camera or movement.

## Implementation and evidence status

`roblox/mvp/server/activities/Q05.luau`, `roblox/mvp/builders/Q05Station.luau`, and `roblox/mvp/tests/q05.spec.luau` are authored. The station requires Task 01's measured `Q05UDistrictVending` anchor and integrator installation. Studio import, live route clearance, exact figure palette/content approval, client/router wiring, mixed-device play, concurrency, reconnect, and independent verification remain open gates. Historical treasure-hunt and personal-wallet behavior is superseded for this MVP; no real-money purchase or gifting UI is included.
