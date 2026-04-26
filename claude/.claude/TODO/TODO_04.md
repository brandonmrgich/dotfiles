Style Extraction Analysis
I read all 8 mocks. The agent did good work — most of the brief was honored and the mocks render cleanly within your existing token system. Below is what I found, then the extraction prompt for Local Claude.
What the agent built well

Token vocabulary is clean. Every color reference is a CSS class (bg-surface, text-foreground-strong, border-border-subtle) — no hex inlined. This means the visual maps directly to your existing globals.css tokens, no token additions needed for the bulk of the design.
Component decomposition matches the brief. Header, MiniPlayer, TabBar, AlbumCard, TrackRow, PlaylistCard, RoomBanner, RoomRow, SectionHeader, SearchInput — each is a distinct component with reused styling.
Bottom-tab IA executed correctly. 4 tabs (Home / Browse / Library / You), accent active state with the under-icon dot, foreground-muted inactive.
Mini-player above the tab bar — exactly the pattern you asked for.
Browse internal segmented tabs — Catalog / Rooms / Artists with the accent underline on active. Clean.

What drifted from the brief
A few small departures worth noting before extraction:

No drag handle on persistent UI. The mock is a static render, so no expanded-player sheet was generated — the brief asked for it but the agent only rendered the mini bar. Not a problem; it's a state we just haven't seen rendered.
Track rows lack the index number — the brief specified "Index (text-sm, foreground-muted, 24px wide) — optional, omitted when not in numbered list" and the agent omitted it everywhere. That's defensible but should be flagged.
AlbumCard title uses text-foreground-strong in browse-horizontal-scroll context but text-foreground-strong in home grid context — consistent in the mocks. Good.
Studio screen drift. The brief specified two distinct Studio variants (Artist with Overview/Stats/Profile/Releases tabs, Listener with Profile/Pinned/Settings tabs). The mocks only show the Listener variant. The agent picked one and ran with it. Not a bug — just a gap to flag.
No banner image, no avatar upload, no full Profile-tab editing surface — the listener Profile tab is just Display Name + Bio + Save, much thinner than the brief specified for Artist. Again, the agent went minimal.
Settings tab toggles are a custom switch component the brief didn't fully spec — pill background, position-shifted thumb. Worth capturing as a new component (Toggle).
Empty state in Pinned is a centered card with helper copy — clean, matches the brief's intent.
Artist row in Browse uses a placeholder filled circle (bg-surface-elevated) instead of an avatar image. That's fine for a mock — the spec calls for 56×56 avatar; the agent used a placeholder. Worth keeping in mind during implementation: real artists will have images.

What's confirmed by the mocks (all consistent across screens)

Layout structure: max-w-[390px] outer frame, header (h-14), main (flex-1 overflow-y-auto), mini-player (h-14), tab-bar (h-16). Total 184px of fixed chrome.
Page padding: px-4 pt-4 is the universal page-content opener.
Section gap: mt-6 between top page section and nav row, mt-8 between major sections, mb-6 between section header and content.
Section header pattern: text-xs uppercase font-semibold text-foreground-muted tracking-wide for the label; right-side action is text-sm text-accent.
Button pattern (primary): w-full h-11 bg-accent-button-bg text-white rounded-full font-medium hover:bg-accent-hover transition-colors.
Button pattern (outline): w-full h-11 bg-transparent border border-foreground-muted text-foreground rounded-full font-medium hover:bg-surface transition-colors.
Card pattern (interactive row): w-full bg-surface rounded-xl p-3 flex items-center gap-3 cursor-pointer hover:bg-surface-elevated transition-colors.
Card pattern (elevated): bg-surface-elevated rounded-2xl p-4.
Search/input pattern: h-11 bg-surface border border-border-subtle rounded-full px-3 for search; form inputs use h-12 px-4 bg-surface border border-border rounded-xl with focus:border-accent.
Form labels: text-sm font-medium text-foreground-muted mb-1 block.

What's new and needs to be added to the design system
Three things show up in the mocks that aren't fully in your existing tokens/components:

bg-presence-live — used for the green "live" dot in rooms. New token. The brief specified #4ade80. Need to add this to globals.css.
bg-accent-button-bg — used for primary CTAs. The brief specified this for AA contrast on white-text-on-coral. Need to add this token.
Toggle component — the iOS-style switch in Settings. Not in your existing primitives; needs to be added or use Radix.

---

Extract the visual design from a series of HTML mocks I'll provide
inline below, and translate it into implementation guidance for
apps/web-audio-player. The mocks are static renders from a third-party
design tool — I have HTML only, no design file access. Your job is to
map the visual to the existing token system, identify what needs to
change, and prepare a clean implementation brief.

## Reference docs (read first)

- docs/10-ui-ux/web-audio-player.md (current state)
- docs/10-ui-ux/design-tokens.md (current tokens)
- docs/10-ui-ux/component-patterns.md (current components)
- docs/10-ui-ux/redesign-explorations/2026-04-mobile-community-pivot.md (the brief that drove the mocks)

## Reference skills

- music-platform-stream-player-ux
- music-platform-architecture
- nextjs-app-router
- web-audio-howler

## What's been extracted from the mocks

The mocks honored the existing token vocabulary from
apps/web-audio-player/src/app/globals.css. Below is the extracted
spec — patterns confirmed across all 8 screens, plus drifts and
gaps to address.

### Screens covered

1. Home — populated, mini-player active
2. Browse → Catalog tab
3. Browse → Rooms tab
4. Browse → Artists tab
5. Library — populated
6. Listener Profile (under "You" tab) → Profile tab
7. Listener Profile → Pinned tab (empty state)
8. Listener Profile → Settings tab

### Layout shell (all screens)

```
┌────────────────────────────────────────┐
│ Header (h-14)                          │  bg-panel/80 backdrop-blur-md sticky top-0 z-50
│ Logo · "Waveform"      Settings · Sun  │  px-4
├────────────────────────────────────────┤
│ Main (flex-1 overflow-y-auto)          │  scrollable page content
│   px-4 pt-4 + page-specific content    │
│   pb-6 final buffer                    │
├────────────────────────────────────────┤
│ MiniPlayer (h-14)                      │  bg-panel
│ [art] Track · Artist  [Pause] [Skip]   │  px-3
├────────────────────────────────────────┤
│ TabBar (h-16)                          │  bg-panel border-t border-border-subtle
│ Home · Browse · Library · You          │  flex justify-around
└────────────────────────────────────────┘
```

Outer container: `w-full max-w-[390px] h-[844px] bg-background overflow-hidden relative flex flex-col`

### Universal page-content rhythm

- Page wrapper opens with: `px-4 pt-4`
- Page heading: `<h1 class="text-2xl font-semibold text-foreground-strong">`
- Section spacing: `mt-6` after page header content, `mt-8` between major sections
- Section header row: `flex items-center justify-between mb-6`
    - Title: `<h2 class="text-xs uppercase font-semibold text-foreground-muted tracking-wide">`
    - Optional right action: `<button class="text-sm text-accent hover:text-accent-hover transition-colors">`
- Item list within section: `space-y-2`

### Reusable patterns confirmed in mocks

**Primary CTA button**

```
w-full h-11 bg-accent-button-bg text-white rounded-full font-medium hover:bg-accent-hover transition-colors
```

**Secondary outline button**

```
w-full h-11 bg-transparent border border-foreground-muted text-foreground rounded-full font-medium hover:bg-surface transition-colors
```

**Accent outline button (used for "+ Create a room")**

```
w-full h-11 border border-accent text-accent rounded-full font-medium hover:bg-accent-muted transition-colors
```

**Interactive row (TrackRow, PlaylistCard, RoomRow, ArtistRow)**

```
w-full bg-surface rounded-xl p-3 flex items-center gap-3 cursor-pointer hover:bg-surface-elevated transition-colors
```

**Elevated card (RoomBanner, Studio profile preview)**

```
w-full bg-surface-elevated rounded-2xl p-4
```

**Search input pill**

```
w-full h-11 bg-surface border border-border-subtle rounded-full px-3 flex items-center gap-2
inner input: flex-1 bg-transparent text-base text-foreground placeholder:text-foreground-muted outline-none
```

**Form text input / textarea**

```
input: w-full h-12 px-4 bg-surface border border-border rounded-xl text-base text-foreground outline-none focus:border-accent transition-colors
textarea: same as input but py-3 instead of fixed height, resize-none
label: text-sm font-medium text-foreground-muted mb-1 block
```

**Genre / category pill (horizontal scroll)**

```
container: flex gap-2 overflow-x-auto pb-2 scrollbar-hide
pill: px-4 py-2 bg-surface border border-border-subtle rounded-full text-sm whitespace-nowrap hover:bg-surface-elevated transition-colors
```

**Segmented tab row (Browse sub-tabs, Studio sub-tabs)**

```
container: flex items-center gap-6 mt-4 border-b border-border-subtle
active button: text-sm font-semibold pb-2 capitalize text-foreground-strong border-b-2 border-accent
inactive button: text-sm font-semibold pb-2 capitalize text-foreground-muted
```

**Tab bar item (bottom nav)**

```
button: flex flex-col items-center justify-center h-full flex-1 relative
icon: 24×24 (lucide), text-accent if active else text-foreground-muted
label: text-[12px] leading-none mt-1, text-accent if active else text-foreground-muted
active dot: absolute bottom-0 w-1 h-1 rounded-full bg-accent
```

**HomeHero card**

```
container: w-full rounded-2xl bg-gradient-to-br from-accent/12 via-background to-secondary-muted p-6 min-h-[360px] flex flex-col relative
eyebrow: inline-flex items-center gap-1.5 bg-accent-muted text-accent px-3 py-1 rounded-full
eyebrow text: text-xs uppercase font-semibold
h1: text-[28px] leading-tight font-semibold text-foreground-strong mt-4
body: text-base text-foreground-muted mt-3 leading-relaxed
CTA group: flex flex-col gap-3 mt-6
slide dots: flex items-center justify-center gap-2 mt-6
  active dot: w-7 h-2 bg-accent rounded-full
  inactive dot: w-2 h-2 bg-foreground-muted/35 rounded-full
```

**RoomBanner**

```
container: w-full bg-surface-elevated rounded-2xl p-4
live row: flex items-center gap-1.5
live dot: w-2 h-2 rounded-full bg-presence-live
live text: text-sm text-foreground-muted (e.g. "47 listening")
title: text-2xl font-semibold text-foreground-strong mt-2
now-playing: text-base text-foreground-muted mt-1
artist: text-sm text-foreground-muted
join button: primary CTA pattern, mt-4
```

**RoomRow**

```
container: interactive-row pattern
left flex-1:
  inner flex: items-center gap-3
    live dot: w-2 h-2 rounded-full bg-presence-live flex-shrink-0
    name: text-base font-semibold text-foreground truncate
  sub-text: text-sm text-foreground-muted truncate mt-0.5 ml-5 (e.g. "Now: Autumn Light")
right flex (gap-2):
  count: text-sm text-foreground-muted (e.g. "◉ 47")
  chevron: lucide-chevron-right 20×20 text-foreground-muted
```

**TrackRow**

```
container: interactive-row pattern
artwork: w-11 h-11 rounded-lg object-cover flex-shrink-0
center flex-1 min-w-0:
  title: text-base font-semibold text-foreground truncate
  meta: text-sm text-foreground-muted truncate (artist · album)
duration: text-xs text-foreground-muted flex-shrink-0
```

**PlaylistCard (compact / library variant)**

```
container: interactive-row pattern
cover: w-14 h-14 rounded-lg object-cover flex-shrink-0
center: title (h3 text-base font-semibold text-foreground truncate) + meta (text-sm text-foreground-muted truncate, "Curator · N tracks")
play button: w-11 h-11 flex items-center justify-center flex-shrink-0, lucide-play 20×20 text-foreground
```

**AlbumCard (home grid + browse horizontal scroll)**

```
container: cursor-pointer group
artwork wrapper: aspect-square w-full rounded-2xl border border-border overflow-hidden
artwork img: w-full h-full object-cover
text wrapper: mt-2
title: text-sm font-semibold text-foreground-strong line-clamp-2
meta: text-xs text-foreground-muted mt-0.5 (e.g. "EP · 2024")

Home grid: parent uses grid grid-cols-2 gap-3
Browse horizontal scroll: parent uses flex gap-3 overflow-x-auto pb-2 scrollbar-hide; each card wrapped in w-[140px] flex-shrink-0
```

**ArtistRow (Browse → Artists)**

```
container: interactive-row pattern
avatar placeholder: w-14 h-14 rounded-full bg-surface-elevated flex-shrink-0
center flex-1:
  name: h3 text-base font-semibold text-foreground
  meta: text-xs text-foreground-muted
chevron: w-5 h-5 text-foreground-muted (custom svg in mock; should use lucide-chevron-right)
```

**Toggle (iOS-style switch — NEW component)**

```
Off state:
  button: w-12 h-7 bg-surface-elevated rounded-full relative
  thumb: w-5 h-5 bg-foreground-muted rounded-full absolute left-1 top-1

On state:
  button: w-12 h-7 bg-accent rounded-full relative
  thumb: w-5 h-5 bg-white rounded-full absolute right-1 top-1
```

### NEW TOKENS that need to be added to globals.css

The mocks reference two CSS classes that don't exist yet:

1. **`bg-presence-live`** — live indicator green dot (`#4ade80`)
    - Add to `:root` (dark): `--app-presence-live: #4ade80;`
    - Same value in light mode (the green works on both backgrounds with sufficient contrast)
    - Add Tailwind theme entry: `--color-presence-live: var(--app-presence-live);`

2. **`bg-accent-button-bg`** — primary CTA background (AA contrast on white text)
    - Dark mode: `--app-accent-button-bg: #e85d52;` (deeper than `--app-accent: #ff6f61`)
    - Light mode: `--app-accent-button-bg: #e85d52;` (matches existing light-mode accent — same value)
    - Add Tailwind theme entry: `--color-accent-button-bg: var(--app-accent-button-bg);`
    - Hover state can continue to use `--app-accent-hover`

### Drifts from the redesign brief

These are gaps where the mocks didn't fully render the brief — flag them but don't try to fill them in this pass:

1. **No expanded PlayerSheet rendered.** The mocks show only the mini-player. The full-screen expanded player (drag handle, large artwork, transport row, visualizer, room indicator) is unrepresented. Implementation will need to follow the brief's spec for that screen, since no visual reference exists.

2. **No artist Studio variant rendered.** The brief specified Studio with Overview/Stats/Profile/Releases sub-tabs for artists; only the listener "You" variant was rendered (Profile/Pinned/Settings). The artist Studio implementation should follow the brief, not the mocks.

3. **TrackRow has no index column.** The brief allowed it as optional ("omitted when not in numbered list"). The mocks omit it everywhere including TrackList contexts. Implementation can follow the mocks (no index) for simplicity.

4. **Profile tab is minimal.** Listener Profile tab in the mocks has only Display Name + Bio + Save button. The brief specified more (avatar upload, banner, social links, accent picker for artists). The artist version is unspecified visually; listener can match the mock's minimal version.

5. **Pinned tab empty state only.** The mocks didn't show populated Pinned. Implementation needs to follow the brief's spec for PinnedItemCard grid layout.

6. **Artist Row uses placeholder circle.** The mock shows `w-14 h-14 rounded-full bg-surface-elevated` as an avatar placeholder. Real implementation needs `<img>` with `object-cover`.

7. **Search input lacks an explicit aria-label.** Audit during implementation.

8. **Toggle component is custom in the mock**, not Radix. We should evaluate whether to use Radix Switch (consistent with existing Radix dialog usage) or implement custom matching the visual.

### What's NOT in the mocks (must come from brief, not visual reference)

These screens/states need implementation per the brief without visual reference:

- PlayerSheet (expanded player overlay)
- Room view (`/rooms/[id]`)
- Artist profile page mobile redesign
- Album page mobile redesign
- Track detail page
- Listener profile (other user) page
- Auth flows (Login, Register step 1, Register step 2)
- Studio (artist variant) — Overview / Stats / Profile / Releases tabs
- Pinned tab populated state
- Empty states for Library, Browse no-results, etc.

## Your task

### Phase 1 — Audit current code against extracted patterns

Inspect the existing apps/web-audio-player codebase and identify:

1. **Components that need updates** — where does current code diverge
   from the patterns above? List each component, the file, and the
   delta (1-2 lines per item).

    Focus on: AppShell, SiteHeader, GlobalPlayer, TrackList, AlbumCard,
    PlaylistCard, HomeHero (likely needs replacement),
    PageNavChrome/Breadcrumbs, MediaContextMenu (no change expected).

2. **Components that need to be created** —
    - BottomTabBar
    - MiniPlayer (refactored from current GlobalPlayer)
    - PlayerSheet (full-screen expanded player)
    - RoomBanner
    - RoomRow
    - RoomView (page-level)
    - BadgePill (deferred — no mock, follow brief)
    - PinnedItemCard (deferred — no mock, follow brief)
    - Toggle (iOS-style switch)
    - ListenerProfilePage
    - ArtistRow

3. **globals.css changes needed** — exact diff to add
   `--app-presence-live` and `--app-accent-button-bg` plus the
   Tailwind theme mappings.

### Phase 2 — Generate implementation brief

Write a single document at:
`docs/10-ui-ux/redesign-explorations/2026-04-mobile-community-pivot-IMPLEMENTATION.md`

Structure:

1. **Token additions** — exact globals.css diff
2. **Component changes** — table of existing components × delta
3. **New components** — for each, signature (props), file path, dependencies
4. **Screen-by-screen implementation order** — logical sequencing of
   what to build first (chrome → screens → flows)
5. **Open questions / decisions deferred** — list of things the mocks
   didn't answer and the brief was ambiguous on
6. **Migration notes** — feature flag strategy if appropriate, given
   the existing app is in production at stream.brandonmrgich.com

### Phase 3 — Update existing UX docs

Update these to match the extracted patterns (not full rewrites,
targeted patches):

- `docs/10-ui-ux/design-tokens.md` — add the two new tokens to the
  color table; update the typography section if Phase 1 reveals any
  drift
- `docs/10-ui-ux/component-patterns.md` — append the new component
  patterns (Toggle, RoomBanner, RoomRow, ArtistRow, MiniPlayer,
  refactored AlbumCard horizontal-scroll variant)
- `docs/10-ui-ux/web-audio-player.md` — flag this is a "current state"
  doc that will diverge from the implementation brief; add a note
  pointing at the IMPLEMENTATION doc

Do NOT delete or rewrite the existing docs — they describe the current
production state, which is still useful context.

### Phase 4 — Stop and report

After phases 1-3, print:

1. The implementation doc's section headings + first paragraph of each
2. List of files touched
3. List of files that WILL be touched during implementation (no edits
   yet — implementation is a separate workstream)
4. Any open questions that surfaced during the audit

Wait for me to review before doing anything else.

## Stop conditions

Stop and ask if:

- The current codebase contradicts the brief in ways that require a
  decision (e.g., a refactor of state management would be needed)
- A "drift" item turns out to be wrong on closer inspection of the mocks
  (the HTML I extracted from might have nuance I missed)
- The implementation doc is heading past 600 lines — surface scope
  concerns

## Do NOT

- Do not start implementation
- Do not modify components yet
- Do not commit
- Do not generate new mock screens or speculate about visual states
  that aren't in the source mocks or the brief
- Do not propose visual changes outside what the mocks/brief specify

-A few notes on what's coming next
The implementation doc is the real product. Once Local Claude finishes, you'll have a single doc that says exactly what to build, what to refactor, and in what order. That becomes the input to a master plan you can run through your plan-executor system — same workflow you used for the admin form overhaul.
Two tokens, one component. The visual extraction is small in delta terms. The mocks honored your existing system tightly, which is good — it means you don't have a "new design system" problem, you have an "extend and add screens" problem. Much smaller scope.
Two screens have no visual reference. PlayerSheet (expanded player) and the Artist Studio variant don't have mocks. Those need to be built from the brief alone, which is fine — the brief is detailed enough — but it means the implementation has more interpretation latitude there than for the mocked screens. Worth being deliberate when you get to those.
The implementation will need feature flagging. The current production app at stream.brandonmrgich.com is desktop-oriented and has users (or at least is publicly accessible). A flag-gated rollout (NEXT_PUBLIC_PLAYER_V2 or similar, mirroring your admin flag pattern) would let you build alongside without breaking the live site. Local Claude can suggest the strategy in Phase 4.
When Local Claude returns its implementation doc, paste it back and we can review it together before moving into actual planning/execution.--
