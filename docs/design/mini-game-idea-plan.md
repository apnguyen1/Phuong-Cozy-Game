# Mini Game Idea Plan

**Project:** Phuong's Cozy World  
**Version:** 0.1 — September 24, 2026  
**Status:** Agreed activity idea and behavior plan; gameplay implementation and playtesting are pending.

This document records the agreed deeper designs for all six activities. It replaces the earlier Q05 treasure hunt with **A Labubu Wish** and authorizes a limited earned-coin and capsule system in the design. Its activity, reward, session-lifetime, and Labubu palette decisions take precedence over conflicting earlier planning text.

The document is the design baseline. The detailed ticket and verifier alignment listed below is subsequent implementation work, not a claim that those updates or any Roblox gameplay have already been completed.

## 1. Overview

Replace **Q05 / PCW-11 — Little Treasures** with **A Labubu Wish**. Players earn personal coins through the other five activities, spend them at a vending machine, and keep or gift the figures they receive.

The chosen collection is **Big into Energy**: Love, Happiness, Loyalty, Serenity, Hope, Luck, and the secret figure ID. Appearance references come from the [official collection](https://www.popmart.com/us/products/2155/THE-MONSTERS-Big-into-Energy-Series-Vinyl-Plush-Pendant-Blind-Box).

The overall experience remains a cooperative Roblox birthday world for 8–10 real participants, supporting mobile, tablet, and desktop. Players keep independent third-person cameras. Activities are gentle, replayable minigames with a shared six-petal completion flower and personal coin wallets.

This plan defines the activity specifications, related ticket changes, and verification requirements. Building the Roblox activities follows these specifications later.

## 2. The six activities

### Q01 — Everything Tucked In

**Ticket:** [PCW-07](../tickets/PCW-07.md)  
**Location:** Phuong's bedroom  
**Activity:** A cooperative arranging game

**Playable sequence:** smooth three rumpled blanket sections → place two pillows → position the dog and dinosaur plushies → choose the final tuck.

Players tap an item and its destination; generous placement areas snap it into position. Incorrect placement gives a gentle hint and costs nothing. Different players can handle different pieces.

Phuong chooses which plush sits on each side and whether the blanket leaves them peeking out or tucked snugly. The host may perform the finishing step if she temporarily disconnects.

**Completion:** all seven preparation steps and the finishing choice are committed. The made bed remains visible and the first completion fills one petal.

**Replay:** a fresh arrangement preview lets friends repeat the activity without unmaking the finished bed. Applying a replacement arrangement belongs to Phuong or the host.

### Q02 — Jasper's Favorite Things

**Ticket:** [PCW-08](../tickets/PCW-08.md)  
**Location:** Jasper's yard  
**Activity:** Discovery and fetch

**Playable sequence:** follow Jasper's sniffing hint → find his rabbit in one of three toy baskets → complete three fetch throws → pet him and give him a Greenie.

The fetch lane has three generous target areas. Players select a target and tap Throw; completing a round requires using each target once. Jasper's running, retrieval, and happy reactions provide the feedback.

Only the throwing action waits while Jasper retrieves. Other players can investigate the rabbit clue or interact with available prompts. Repeated pet taps cannot manufacture additional contribution credit.

**Completion:** rabbit found, three targets used, petting completed, and treat given. The first completion fills one petal.

**Replay:** change the rabbit's basket and target order. There is no accuracy score, recurring cleanup chore, or punishment.

### Q03 — A Tiny World of Her Own

**Ticket:** [PCW-09](../tickets/PCW-09.md)  
**Locations:** Bedroom desk and street-fair craft booth  
**Activity:** A miniature assembly puzzle

**Playable sequence:** choose pieces → rotate with quarter-turn buttons → match them to visible spaces → light the finished scene.

The first miniature contains six pieces: a rug, chair, bookcase, side table, plant, and lamp. Placement checks the correct piece and orientation; nearby valid placements snap into place. Wrong attempts remain available to retry.

The bedroom desk and street-fair booth contribute to the same miniature. Players reserve individual spaces while working, leaving other spaces available.

**Completion:** all six pieces are fitted and Phuong or the host selects the finishing arrangement and lights the lamp. The miniature remains displayed at home; one petal is awarded once.

**Replay:** assemble another arrangement in a shared preview. Replacing the displayed version requires Phuong's or the host's choice.

### Q04 — One More Chapter

**Ticket:** [PCW-10](../tickets/PCW-10.md)  
**Locations:** Kindle at home or a Quad bench  
**Activity:** An expressive reading activity

**Playable sequence:** choose one of three short original passages → select a highlighted phrase → choose a reaction → decorate and save a bookmark.

Use approximately 50–80 words per passage, three selectable phrases, four reactions, and three bookmark styles. Every interpretation is valid. Typing is optional, and there is no quiz.

Players contribute bookmarks to a shared reading display while reading independently. Saving the first complete bookmark fills the shared reading petal; other readers continue without interruption and earn their own completion rewards.

**Completion:** a phrase, reaction, and bookmark style are saved.

**Replay:** start a fresh bookmark contribution, optionally choosing another passage. Reopening or resaving an existing bookmark does not earn coins. Closing midway preserves that contribution's progress within the session.

### Q05 — A Labubu Wish

**Ticket identity:** PCW-11, replacing the earlier Little Treasures design  
**Location:** The existing fair display area  
**Activity:** A capsule vending-machine game

Place the machine beside the existing fair display area, outside the clear walking lane.

**Playable sequence:** inspect the seven figures → select a wanted figure → spend 20 coins → open the capsule → keep the result or offer a gift.

Each player has a personal collection and wanted-figure tracker. Several players can use the machine through their own interfaces without reserving the whole cabinet.

The reveal is short and skippable. The figure is awarded before the animation, so closing the interface or disconnecting cannot lose it.

**Completion:** Phuong obtains her selected wanted figure through her own roll or an accepted gift. This fills Q05's petal once. Shelf placement is optional afterward.

**Replay:** continue collecting, select another wanted figure after fulfilling the current wish, and gift extra copies. Rolling and gifting never award coins.

### Q06 — Something Delicious

**Ticket:** [PCW-12](../tickets/PCW-12.md)  
**Location:** Cooking and birthday patio  
**Activity:** Cooperative preparation and serving

The first round contains three parallel jobs:

- **KBBQ:** prepare and grill two servings, turn them when a clear visual cue appears, then plate them.
- **Seafood boil:** select shrimp, corn, and potatoes from illustrated ingredient choices and assemble the platter.
- **Table setting:** arrange four place settings and choose a small centerpiece.

Grilling uses a forgiving three-second cooking animation per side. Food remains ready until acted on; it never burns. An early tap explains the next action without losing progress.

**Completion:** both grilled servings, the seafood platter, and four place settings are ready. Food remains on the table, and one petal fills once.

**Replay:** prepare another serving round while the completed birthday table remains intact. Keep cooking positions clear of the cake gathering area.

## 3. Coins, rolls, and gifts

| Rule | Agreed behavior |
|---|---|
| Starting wallet | 0 coins |
| First completion | 20 coins per player, per earning activity |
| Later completed rounds | 10 coins |
| Capsule price | 20 coins |
| Regular figures | 16.5% each |
| Secret ID | 1% |
| Wanted guarantee | After four unsuccessful rolls, the fifth awards the selected figure |
| Duplicates | Keep or gift; no selling or refunds |
| Purchases | Coins come only from activities; no Robux or real-money purchases |
| Lifetime | Current running birthday session only |

These are the game's custom odds, independent of physical blind-box odds. The six regular probabilities plus the secret probability total 100% before the wanted guarantee applies.

### Earning coins

For cooperative rounds, a player earns coins only after contributing at least one distinct, required action that the server accepts and the round successfully completes. Watching, joining, invalid attempts, and repeated taps earn nothing. Reading rewards a completed bookmark contribution.

Each player's first-completion bonus is tracked separately from the shared flower. A late joiner can earn their first 20 coins by helping with a replay. Five first completions therefore fund five capsules and the guaranteed wanted figure.

### Choosing a wanted figure

A wanted selection stays locked until fulfilled. Receiving it through an accepted gift also fulfills the wish. Afterward, selecting another figure starts a new guarantee counter. Selecting a figure already owned fulfills that selection immediately.

The fifth-roll guarantee applies to any selected figure, including ID. Finding the wanted figure earlier fulfills the wish immediately; the player does not have to finish five rolls.

### Gifting

Gifts transfer one owned copy to Phuong after she accepts. An offered copy is reserved until acceptance, rejection, cancellation, or a 60-second expiry. Disconnecting either participant cancels a pending offer and releases the copy. Accepted gifts remain owned for the session. Coins cannot be transferred.

## 4. Shared behavior and specification changes

### Multiplayer, replay, and session state

- Preserve one shared six-petal flower. Coins can recur across completed rounds; petals cannot.
- Retain wallets, collections, contributions, and guarantee counters by player identity while the server remains running. Reconnecting to that server restores them. A different server or restarted session begins fresh.
- Preserve accepted activity steps when someone cancels or disconnects. Release only their unfinished reservations. A completed round credits qualifying contributors even if they temporarily disconnected.
- Use individual slot reservations with a 15-second inactivity expiry. A departing player cannot hold an entire activity.
- Keep touch and desktop controls equivalent, maintain independent cameras, and avoid forced warps.
- Aim for roughly two to four minutes per first solo activity; cooperative groups may finish faster. Playtests determine pacing without adding artificial waiting.

### State and action interfaces for future implementation

Document server-owned activity rounds, contribution records, wallets, inventory counts, wanted selections, and transaction receipts. Activity rewards, capsule purchases, and gifts must each apply once despite repeated requests. Clients request actions; the server validates progress, balances, ownership, and random outcomes.

### Ticket and document alignment to implement next

Update the active activity tickets and dependent UI, shared-state, map, content, rehearsal, and verification documents. Remove the six-hidden-figures/three-required completion rule. Keep the bedroom shelf as a collection display. Replace the blanket prohibition on an economy with permission for this specific earned-coin system.

Retain Q05 and PCW-11 as stable identities so the replacement remains one of the six activities rather than becoming a seventh quest. Older tickets and verifier text must be aligned with this plan before they are used to approve a production implementation of the new activity.

### World and figure palettes

For art verification, keep the [eight world colors](../../verification/palette.json) unchanged:

| Token | Hex |
|---|---|
| forest | `#365744` |
| sage | `#A8B995` |
| cream | `#F5F0E4` |
| wood | `#95674B` |
| blossom | `#E8B7C6` |
| brick | `#B66C68` |
| golden | `#E8C779` |
| ink | `#26382E` |

Add an explicitly selected, approved figure palette profile for faithful Big into Energy assets. Figure profiles require reviewed references and exact swatches before production approval; they cannot authorize extra colors on buildings, UI, or the machine. Include profile files in revision fingerprints.

## 5. Verification and acceptance

The updated verifier must cover:

- **Each activity:** solo completion by Phuong, cooperative contributions, touch/desktop use, incorrect actions, cancellation, re-entry, and three completed replays.
- **Rewards:** first clear pays 20, later rounds pay 10, spectators receive nothing, and duplicate requests cannot repeat a payout or petal.
- **Gacha:** insufficient funds, all seven outcomes, correct probability weights, an early wanted win, four misses followed by the guaranteed fifth result, and no debit without an award.
- **Gifts:** acceptance, rejection, expiry, disconnects, simultaneous attempts to gift one copy, and exactly one Q05 petal when Phuong receives her target.
- **Recovery:** reconnect during an activity, reward payment, capsule reveal, and gift transaction; new sessions reset as specified.
- **Art:** recognizable figure variants and expressions, approved figure colors, unchanged world palette, readable machine controls, and correct Studio scale/materials.
- **Human playtest:** satisfying actions, clear contribution credit, enjoyable capsule reveals, understandable guarantee progress, and enough variety to make earning more coins appealing.

Retain the existing **build → verify → playtest → revise → retest** workflow in the [verification guide](../../verification/README.md). The birthday gathering still follows six petals, remains host-controlled, and leaves activities available afterward. Personal birthday-note content stays user-authored.
