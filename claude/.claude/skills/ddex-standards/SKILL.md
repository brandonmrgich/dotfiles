---
name: "[HomebrewSkill] ddex-standards"
description: DDEX (Digital Data Exchange) standards reference for music industry messaging. Covers the five core standard suites (ERN for release delivery, RDR for recording rights and revenue, MWDR for musical work rights, RIN for studio session metadata, MEAD for marketing metadata), the key industry identifiers (ISRC, ISWC, IPI, ISNI, GRid, DPID, HFA Song Code, UPC/EAN), the right share concepts (Manuscript/Writer Share, Original Publisher Share, Collection Share), and the end-to-end data flow between studios, labels, distributors, DSPs, and collecting societies. Trigger when the prompt or files in scope mention any of: DDEX, ERN, RDR, MWDR, RIN, MEAD, NewReleaseMessage, DealList, CommercialModelType, UseType, Letter of Direction, LoD, Right Share, Manuscript Share, Collection Share, Publisher Share, Writer Share, ISRC, ISWC, IPI, ISNI, GRid, DPID, HFA Song Code, mechanical license, neighboring rights, sound recording rights, musical work rights, P-Line, C-Line, royalty registration, performer rights, rights controller, equitable remuneration, IsCredited flag, IsCredited, featured performer, non-featured performer, session musician credit, MLC, CISAC, CRO, collecting society, royalty registration, distribution metadata standard. This skill is the authoritative reference for DDEX-native concepts like IsCredited, P-Line, C-Line, MWN, MWL, LoD, and the AVS code lists, even when the host project does not yet implement those standards. Do NOT trigger for general music streaming or playback features unrelated to rights data exchange.
---

# DDEX Standards Reference

You are a domain reference for DDEX standards. Activate alongside whatever
role the agent is performing.

## Status note for the music-platform-monorepo

If working in the `music-platform-monorepo` repo: DDEX message construction
(ERN, RDR) is NOT actively implemented. The schema is *aligned* with DDEX
concepts (ISRC, ISWC, IPI, ISNI, performer roles, RoyaltySplit,
RightsOwnership) but the system does not currently emit ERN messages or
consume RDR-R. The roadmap mentions distribution job types but processors
aren't built.

This skill is therefore primarily a **concept and identifier reference**
for schema decisions and identifier handling, not an active message-format
implementation guide.

## The five DDEX standard suites

### ERN (Electronic Release Notification)
- Primary mechanism for label/distributor → DSP delivery
- Core message: `NewReleaseMessage` with three layers:
  1. **Release metadata** — title, artist, GRid, UPC, P/C-line, dates
  2. **Resource metadata** — ISRC per track, contributors, technical specs
  3. **Deal terms (DealList)** — territory, CommercialModelType, UseType,
     start/end dates, pricing
- Profiles: Audio, Music Video, Mixed Media, Ringtone, Classical, Karaoke
- Choreographies: SFTP/cloud file delivery OR web service exchange
- ERN messages are "statements of truth" — new message replaces prior metadata

### RDR (Recording Data and Rights)
- Sub-standards:
  - **RDR-N** — register sound recordings with MLCs/CROs
  - **RDR-R** — revenue reported back from MLCs to labels/performers
  - **RDR-C** — protocol/choreography for exchange
  - **RDR-RCC** — claim conflict notification
- Captures performer-level data (featured vs session, IsCredited flag)
- Territorial rights controllers, P-Line, C-Line
- Links sound recording (ISRC) to musical work (ISWC)

### MWDR (Musical Works Data and Rights Communication)
- Sub-standards:
  - **MWN** — query/response for ownership shares
  - **MWL** — US mechanical license requests (works with MLC infrastructure)
  - **LoD** — US Letters of Direction for ownership transfer
- Right share concepts:
  - **Manuscript / Writer Share** — agreed between writers; sums to 100%
  - **Original Publisher Share** — first publisher in chain of title
  - **Collection Share** — payable share used for actual revenue distribution
- Shares must sum to 100% per territory + rights type
- Integrates with CWR (Common Works Registration) for collecting society interop

### RIN (Recording Information Notification)
- Studio session metadata: contributors, instruments, equipment, locations
- Travels with audio files through the production chain
- Distinct studio events: tracking, overdub, mix, master
- Critical for session musician attribution and royalty accuracy

### MEAD (Media Enrichment and Description)
- Non-core marketing metadata: lyrics, editorial content, mood/theme,
  chart history, focus track designation, classical extensions
- Sent in parallel with ERN, not as a replacement
- 30+ distinct metadata mechanisms supported

## Key identifiers (use precisely)

| Identifier | Type | Standard | Notes |
|---|---|---|---|
| ISRC | Sound Recording / Music Video | ISO 3901 | **Primary cross-system matching key** |
| ISWC | Musical Work | ISO 15707 | Composition, not recording |
| IPI | Writer/Publisher | CISAC | Required for accurate rights matching |
| ISNI | Person/Organisation | ISO 27729 | Public identity |
| GRid | Release (digital) | IFPI | Digital product identifier |
| UPC/EAN | Release (physical/digital) | GS1 | 12-digit UPC-A or 13-digit EAN-13 |
| DPID | DDEX Party Identifier | DDEX | Assigned at dpid.ddex.net |
| HFA Song Code | US Musical Work | HFA | Used by YouTube for rights reconciliation |

**ISRCs are the most reliable cross-system matching key.** Always use them
as primary identifiers for sound recordings.

## Right share rules

- Manuscript/Writer shares always sum to 100% across all writers
- Publisher shares can vary by territory and rights type (mechanical vs
  performance)
- Collection Shares are the payable shares used for actual revenue
  distribution
- Shares communicated using `RightSharePercentage` with sufficient decimal
  precision
- Co-ownership is explicitly modelled — multiple publishers can each hold
  a percentage of the same work
- Letters of Direction (LoD) communicate Collection Share transfers when
  ownership changes

## Performer rights data (RDR)

For sound recording rights:

- Performer name (canonical and display variants)
- Performer role (featured artist, session musician, conductor, etc.)
- `IsCredited` flag — distinguishes credited (public credit + payment) from
  uncredited (payment only)
- IPI and ISNI identifiers
- Territory of the performance right
- Instrumentation details

This data drives equitable remuneration and neighboring rights payments.

## End-to-end data flow

| Stage | Standard | Sender → Receiver |
|---|---|---|
| Studio recording | RIN | Studio → Label |
| Release to DSPs | ERN | Label → DSP |
| Marketing metadata | MEAD | Label → DSP |
| Sound recording rights registration | RDR-N | Label → MLC |
| Musical work rights query | MWN | DSP/Label → Publisher/CRO |
| Mechanical license (US) | MWL | DSP/Label → Publisher/HFA |
| Ownership transfer | LoD | Acquiring Publisher → DSP/Label |
| Revenue reporting | RDR-R | MLC → Label |

## Implementation notes

- **Format**: XML, UTF-8, ISO 3166-1/-3 territory codes (DSR and CDM are
  flat-file exceptions)
- **Validation**: Use official DDEX XSDs
- **AVS / Code Lists**: Allowed Value Sets govern role codes, use types,
  commercial model types — NEVER invent values
- **Timestamps**: Always include timezone designators
- **Licensing**: Free DDEX Implementation Licence required (no membership);
  DPID assigned at dpid.ddex.net
- **Territorial data**: Prefer `Worldwide` with country-level overrides
  rather than enumerating every country
- **Right shares**: Use sufficient decimal precision; rounding errors
  compound at scale

## Common mistakes to flag

- Treating ERN as additive instead of "statement of truth"
- Missing IPI for writers/publishers (breaks rights matching)
- Assuming worldwide rights when data is territory-specific
- Confusing ISRC (recording) with ISWC (composition)
- Using non-DDEX role codes outside the AVS
- Not handling RDR-RCC conflicts as a structured workflow
- US-specific patterns (MWL, LoD) applied outside the US
- Single-publisher assumption when co-ownership is the norm

## What you must never do

- Do not invent DDEX message elements or attributes that aren't in the
  official XSDs.
- Do not provide implementation code without specifying which DDEX version
  it targets (ERN-3 vs ERN-4 vs ERN-5).
- Do not paraphrase right share rules — sums to 100% per territory +
  rights type is mandatory.
- Do not provide US-only guidance (MWL, LoD, MLC, HFA) for non-US scenarios
  without flagging the territorial scope.
