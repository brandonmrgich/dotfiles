---
name: "[HomebrewSkill] royalty-splits-music"
class: specialist
description: "Use when the prompt or files in scope mention music royalty splits or payouts: royalty split, RoyaltySplit, split sheet, MASTER vs PUBLISHING bucket, sum-to-100 invariants, recording-vs-release scope (XOR), payout, donation payout, recoupment, advance, withholding, mechanical royalty, performance royalty, neighboring rights, equitable remuneration, ContentID revenue, songwriter / publisher / writer / master / collaborator share, RightsOwnership, royalty allocation, or paths under /payouts/, /splits/, /royalties/, /donations/. Also covers the sound-recording vs musical-work (publishing) split, 50/50 label-vs-performers neighboring-rights split, featured vs non-featured performer payment, and the deferred-payout state typical of indie platforms before distributor payout adapters land. Do NOT trigger for generic financial accounting or unrelated music metadata."
---

# Music Royalty Splits & Payouts

Domain reference for royalty split modeling and payout flows. Pairs with
`ddex-standards` for the messaging side.

## Two royalty streams from a single play

Every streamed song generates TWO distinct streams, separately calculated
and reported, often by different entities. Conflating them is a common bug.

| Stream | Bucket | Paid to | Sub-types |
|---|---|---|---|
| Sound recording | MASTER | Recording owner (label / indie via distributor) | — |
| Musical work | PUBLISHING | Songwriters + publishers | Performance (PROs), Mechanical (MLC in US) |

## Split modeling (MASTER / PUBLISHING bucket pattern)

Aligned with DDEX rights types:

- Two buckets per scope: `MASTER` and `PUBLISHING`, each summing to 100%
- Scope is XOR: a split row attaches to EITHER a recording OR a release,
  never both

See `examples/types.example.ts` for `RoyaltySplit` / `RightsType` shape
(buckets, XOR `recordingId` / `releaseId`, optional ISO-3166 `territory`).

Validation invariants:

- Sum per (scope, rightsType, territory) must equal 100
- Cannot attach a row to both `recordingId` and `releaseId`
- Re-validate after delete (deletes can leave a bucket at 75%)

## Donation-driven payout (typical indie platform model)

Independent platforms with their own player often run a donation flow
rather than DSP-style streaming royalties:

1. Listener tips on a track → Donation row with `releaseId` or `recordingId`
2. Worker reads `RoyaltySplit` rows for that scope
3. Allocates donation per split percentage → `Payout` rows per Person
4. Payouts accumulate to threshold; processor cuts checks/transfers

Differences from DSP payouts: per-donation allocation (not pro-rata pool),
per-track resolution, no DSP intermediary, recoupment rare (artists are
self-distributed).

## DSP-style payouts (deferred / future state)

Concepts that apply once DSP distribution adapters land (DistroKid,
Bandcamp, BMI/ASCAP, etc.):

- **Recoupment** — advances offset future royalties. Cross-collateralized
  vs single-release; retail vs wholesale recoupment; unrecouped balance
  carries indefinitely.
- **Withholding** — W-9 (US) vs W-8BEN (foreign, 30% default without);
  60-90 day chargeback reserve; recoupment offsets; disputed-claims hold.
- **Currency conversion** — DSPs report in their currency; converted at a
  specific date's rate. Always store original + converted + rate + rate date.
- **Accounting periods** — DSPs report monthly with 60-90 day lag. Splits
  apply to the **streaming period**, NOT the **payout period**.
- **No single per-stream rate** — varies by DSP, subscriber tier, country,
  time of month, free vs paid. DSPs use pro-rata pool: total subscription
  revenue × (this song's share of total streams), NOT fixed-rate × streams.

## Mechanical royalties (US specifics)

- **Statutory rate** — set by Copyright Royalty Board (CRB) every 5 years
- **MLC** — administers blanket mechanical licenses for streaming since
  MMA 2018; **Phonorecords IV** ruling raises streaming mechanical through 2027
- **Black box** — unmatched mechanicals held by MLC, distributed by market
  share if unclaimed
- **HFA** — historical mechanical collector; still active for some catalogs

## Neighboring rights & performer payment

Sound-recording-only performance royalties (terrestrial radio in many
countries — NOT US for non-digital broadcasts; SoundExchange handles US
digital satellite/internet performance).

- **Equitable remuneration** — 50% label / 50% performers (default 45/45/10
  label / featured / non-featured pool; varies by country)
- **Featured performer** — primary or named-featured artist; larger share
- **Non-featured (session) musician** — backing; pool share, much smaller
- **`IsCredited` flag** — credited (public credit + payment) vs uncredited
  (payment only)

The MASTER bucket pattern handles this: featured + session performers
share the bucket with appropriate percentages.

## Common implementation pitfalls

1. Storing only net revenue — keep gross + deductions for audit
2. Mutating split rules in place — splits must be VERSIONED; historical
   periods need historical splits
3. Floating-point currency — use integer cents or arbitrary-precision decimals
4. Single-currency models — multi-currency from day one is far cheaper than
   retrofitting
5. Skipping reserve handling — chargebacks happen
6. Missing audit trail — every payout must be reproducible from source data
7. Confusing payout date with earning date — splits, taxes, recoupment
   depend on when streams happened
8. Treating mechanical and performance as one — different rates, collectors,
   cadences
9. Sum validation only on create/update, not delete — bulk replace is cleaner
   than per-row
10. Currency conversion at payout date — FX risk should belong to the
    platform, not the artist

## Recommended split mutation pattern

Bulk replace per scope, not incremental upsert:

```
PUT /royalty-splits?scope=recording&id=<id>&rightsType=MASTER
body: { splits: [...] }   // entire bucket, replaces atomically
```

Avoids the partial-state problem: per-row "create 50%" fails sum != 100;
bulk replace validates and commits all rows together.

## When to consult `ddex-standards` instead

DDEX message construction (RDR-R revenue reports, MWN ownership queries),
ISRC/ISWC linking, IPI/ISNI usage, neighboring-rights protocol details.
This skill is the business-logic side (calculation, allocation, payout
flow); DDEX is the messaging side.
