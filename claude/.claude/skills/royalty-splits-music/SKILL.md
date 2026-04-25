---
name: "[HomebrewSkill] royalty-splits-music"
description: Music royalty split modeling, payout flows, and revenue allocation. Covers split sheet structure, MASTER vs PUBLISHING bucket separation, sum-to-100 invariants per bucket and territory, recording-vs-release scope (XOR), donation-driven payout models (as used in independent web audio player donation flows), the relationship between sound recording rights and musical work rights (publishing), neighboring rights and equitable remuneration (50/50 label/performers split), featured vs non-featured performer payment differences, and the deferred state (no automated DSP payouts yet) typical of indie music platforms before distributor payout adapters land. Trigger when the prompt or files in scope mention any of: royalty split, RoyaltySplit, split sheet, MASTER bucket, PUBLISHING bucket, sum to 100, payout, donation payout, recoupment, advance, withholding, mechanical royalty, performance royalty, neighboring rights, equitable remuneration, ContentID revenue, songwriter share, publisher share, writer share, master share, collaborator royalty, RightsOwnership, royalty allocation, /payouts/, /splits/, /royalties/, /donations/. Do NOT trigger for generic financial accounting or unrelated music metadata.
---

# Music Royalty Splits & Payouts

Domain reference for royalty split modeling and payout flows. Pairs with
`ddex-standards` for the messaging side.

## The two royalty streams from a single play

Every streamed song generates TWO distinct royalty streams:

1. **Sound recording (master) royalty** — paid to the recording owner
   (label, indie artist via distributor)
2. **Musical work (publishing) royalty** — paid to songwriters and publishers
   - **Performance royalty** — for public performance (collected by PROs)
   - **Mechanical royalty** — for reproduction (collected by MLC in US)

These are separately calculated, separately reported, and often paid by
different entities at different times. Conflating them is a common mistake.

## Split modeling (the MASTER / PUBLISHING bucket pattern)

The pattern used in indie music platforms (and aligned with DDEX rights
types):

- Two buckets: `MASTER` and `PUBLISHING`
- Each bucket sums to 100% per scope
- Scope is XOR: a split row attaches to EITHER a recording OR a release,
  never both

```typescript
type RightsType = 'MASTER' | 'PUBLISHING'

type RoyaltySplit = {
  personId: string         // payee
  rightsType: RightsType   // bucket
  percentage: number       // 0-100
  recordingId?: string     // XOR
  releaseId?: string       // XOR
  territory?: string       // ISO 3166 or 'WORLD'
}
```

Validation invariants:

- Sum per (scope, rightsType, territory) must equal 100
- Cannot have splits attached to both `recordingId` and `releaseId` on the
  same row
- Re-running validation after delete is required (deletes can leave a bucket
  at 75%, breaking the invariant)

## Donation-driven payout (typical indie platform model)

Independent music platforms with their own player often run a donation
flow rather than DSP-style streaming royalties:

```
Listener tips $X on a track
  ↓
Donation row created with releaseId or recordingId
  ↓
Worker reads RoyaltySplit rows for that scope
  ↓
Allocates donation amount per split percentage
  ↓
Creates Payout rows per Person
  ↓
Payouts accumulate until threshold; payment processor cuts checks/transfers
```

Key differences from DSP payouts:

- Per-donation allocation, not pro-rata pool
- Per-track tipping resolution (not aggregated streams)
- No DSP intermediary — direct creator payment
- Recoupment less common (artists are typically self-distributed)

## DSP-style payouts (deferred / future state)

When DSP distribution adapters land (DistroKid, Bandcamp, BMI/ASCAP, etc.),
additional concepts apply:

### Recoupment

When advances are paid, future royalties offset before payout:

- Cross-collateralized: advance recouped from any release's earnings
- Single-release: advance only recouped from that release
- Retail vs wholesale recoupment: massive practical difference
- Unrecouped balance carries indefinitely

### Withholding

- Tax: W-9 (US) vs W-8BEN (foreign); 30% default without W-8BEN
- Refunds/chargebacks: 60-90 day reserve typical
- Recoupment offsets
- Disputed claims (overlapping ContentID, etc.)

### Currency conversion

- DSPs report in their currency (USD, EUR, GBP)
- Distributor converts at rate prevailing on a specific date
- Always store: original currency + converted currency + rate + rate date

### Accounting periods

- DSPs typically report monthly with 60-90 day lag
- Split rules apply to the **streaming period**, NOT the **payout period**
- If splits change in March, March streams use new splits even if paid in May

### Per-stream rates: there is no single rate

Real rates vary by:

- DSP (Spotify ~$0.003-0.005, Apple ~$0.007-0.01, YouTube ~$0.001-0.002)
- Subscriber tier (premium / free / family / student)
- Country (US/UK/EU >> emerging markets)
- Time of month (DSP revenue and total stream volume fluctuate)
- Free trial vs paid

DSPs use "pro-rata pool": total subscription revenue × (this song's share of
total streams). NOT a fixed rate × streams.

## Mechanical royalties (US specifics)

- **Statutory rate** set by Copyright Royalty Board (CRB) every 5 years
- **MLC (Mechanical Licensing Collective)** administers blanket mechanical
  licenses for streaming since MMA 2018
- **Phonorecords IV** ruling: streaming mechanical rate increases through 2027
- **Black box** royalties: unmatched mechanicals held by MLC, distributed
  by market share if unclaimed after holding period
- **HFA (Harry Fox Agency)**: historical mechanical collector; still active
  for some catalogs

## Neighboring rights (sound recordings only)

- Performance royalties for terrestrial radio in many countries
  (NOT US for non-digital broadcasts)
- US: SoundExchange handles digital performance royalties from
  satellite/internet radio
- Equitable remuneration: 50% to label, 50% to performers
  (featured + non-featured)
- Featured artist split typically negotiated; default 45/45/10
  (label / featured / non-featured pool) varies by country

## Featured vs non-featured performer distinction

Critical for neighboring rights and some streaming royalty splits:

- **Featured performer** — primary artist or named featured artist on the
  release; receives larger share
- **Non-featured (session) musician** — backing musician; receives share
  from a pool, typically much smaller
- **`IsCredited` flag** — distinguishes credited (public credit + payment)
  from uncredited (payment only)

The MASTER bucket modeling pattern handles this by including both featured
and session performers in the bucket with appropriate percentages.

## Common implementation pitfalls

1. **Storing only net revenue** — always store gross + deductions for audit
2. **Mutating split rules in place** — splits should be VERSIONED, never
   updated; historical periods need historical splits
3. **Floating-point currency** — always integer cents (or arbitrary-precision
   decimals)
4. **Single-currency models** — multi-currency from day one is much cheaper
   than retrofitting
5. **Skipping reserve handling** — chargebacks happen; need reserve mechanism
6. **Missing audit trail** — every payout calculation must be reproducible
   from source data
7. **Confusing payout date with earning date** — splits, taxes, recoupment
   depend on when streams happened, not when they paid out
8. **Treating mechanical and performance as one** — different rates,
   different collectors, different reporting cadences
9. **Sum validation only on create/update, not delete** — deleting a split
   row can leave a bucket at 75%; bulk replace is cleaner than per-row
10. **Currency conversion at payout date instead of streaming date** —
    introduces FX risk that should belong to the platform, not the artist

## Recommended split mutation pattern

Bulk replace per scope, not incremental upsert:

```
PUT /royalty-splits?scope=recording&id=<id>&rightsType=MASTER
body: { splits: [...] }   // entire bucket, replaces atomically
```

This avoids the partial-state problem during build-up:

- Without bulk replace: first row "create 50%" fails (sum != 100)
- With bulk replace: send all rows together, validate together, commit together

## When to consult `ddex-standards` instead

DDEX message construction (RDR-R revenue reports, MWN ownership queries),
ISRC/ISWC linking, IPI/ISNI usage, neighboring rights protocol details.

This skill covers the business logic side (calculation, allocation, payout
flow). DDEX covers the messaging side.
