---
name: web-audio-howler
class: specialist
description: "Use when the prompt or files in scope reference Howler.js (Howler, howler.js, Howl, html5:true / html5:false), the Web Audio API (AudioContext, MediaElementAudioSourceNode, createMediaElementSource, AnalyserNode), or the MediaSession API (navigator.mediaSession, mediaSession.metadata, mediaSession.setPositionState, MediaMetadata, play/pause/seekto/seekbackward/seekforward action handlers). Also triggers on audio playback, audio visualizer / analyzer / waveform, audio engine, lock screen audio, hardware media keys, OS audio integration, the dual-path Howler+Web-Audio architecture, the createMediaElementSource one-per-element constraint with WeakMap caching, AudioContext priming on user gesture, identity-vs-position effect split for MediaSession ownership hooks, and cross-app / cross-tab playback ownership via BroadcastChannel. Do NOT trigger for generic audio file format questions unrelated to playback."
---

# Web Audio + Howler Specialist

Domain expert on browser-based audio playback combining Howler.js with
Web Audio API analysis and MediaSession integration.

## The architecture problem this skill solves

Three things people commonly want simultaneously:

1. **Cross-browser audio playback** with format fallbacks → Howler.js
2. **Audio visualization / analysis** (waveforms, EQ, beat detection) → Web Audio API
3. **OS integration** (lock screen, hardware keys, "now playing") → MediaSession API

These three want to use the same audio source but have conflicting
requirements. The dual-path architecture is the standard answer.

## The dual-path architecture

```
Howler (html5: true) → <audio> element ─┬─→ speakers
                                        └─→ AudioContext → MediaElementAudioSourceNode → AnalyserNode → destination (silent)
```

Two key points:

1. **Howler with `html5: true`** plays through `<audio>` elements. This
   is what binds to MediaSession (especially on iOS).
2. **The analyzer path** taps the `<audio>` element via Web Audio API for
   visualization, but DOES NOT route playback through Web Audio (that
   would break MediaSession binding).

## Howler html5 mode

```ts
import { Howl } from 'howler'

const sound = new Howl({
  src: ['track.mp3'],
  html5: true,  // critical for MediaSession + iOS
})
```

| Setting | Implementation | MediaSession works | iOS works |
|---|---|---|---|
| `html5: true` | `<audio>` element | ✅ | ✅ |
| `html5: false` (default) | Web Audio buffer source | ❌ unreliable | ❌ broken |

**For any production audio app with OS integration: `html5: true`.**

## The MediaElementAudioSourceNode constraint

The Web Audio spec allows ONLY ONE `MediaElementAudioSourceNode` per
`HTMLMediaElement`. Calling `createMediaElementSource(audioElement)` twice
on the same element throws.

Howler can reload sources, recycle audio elements, etc. The fix: cache
sources per element using `WeakMap` (keyed on the `HTMLMediaElement` so
the entry is garbage-collected when the element is). Full pattern in
the audio-engine example below.

## AudioContext priming

Browsers require a user gesture to start an `AudioContext`. Create it
lazily, then call `ctx.resume()` from a click/tap/keydown handler the
first time. See `primeOnGesture` in the audio-engine example below.

If the analyzer's `AudioContext` isn't primed, visualizations show all
zeros even though playback is audible (because Howler's `<audio>` element
plays independently of the suspended context).

## MediaSession integration

Three concerns, three separate effects:

1. **Identity** (metadata + handlers) — runs when track or handlers
   change. Set `MediaMetadata`, register the five action handlers
   (play/pause/seekto/seekbackward/seekforward), update `playbackState`.
   **Don't unregister handlers on pause** — the hardware Play key must
   reach `onPlay` while paused. Clear only on unload/unmount.
2. **Position** (separate effect, ticks ~4Hz) — `setPositionState` with
   `{ duration, position, playbackRate }`. Wrap in try/catch (some
   browsers throw on NaN duration). This drives the lock-screen
   scrubber and drag-to-seek.
3. **Cleanup** — on unload/unmount, set metadata to `null` and
   playbackState to `'none'`; handlers don't need explicit clearing.

**Why two effects:** position updates frequently. If you bundle it with
metadata + handlers, you re-register all handlers 4×/sec — wasteful and
flickers on some browsers.

**Full code:** `~/.claude/skills/web-audio-howler/examples/mediasession.example.ts`
— identity / position / cleanup effects plus the BroadcastChannel
ownership pattern below.

## Cross-app / cross-tab ownership

If multiple tabs or apps want to coordinate "only one plays at a time,"
`BroadcastChannel` is the right primitive — NOT `window.dispatchEvent`
(that's same-tab only). One tab posts `{ type: 'PLAYBACK_STARTED',
appId }`; other tabs listen and pause themselves when the appId differs.
See the example file above.

For OS-level "interrupt other apps when this one plays" (e.g. pause
Spotify when your app plays): just having `html5: true` Howler binds the
MediaSession, which the OS uses to manage focus. No additional
coordination needed.

## Common pitfalls

1. **`html5: false` (Howler default)** — breaks MediaSession on iOS
2. **Calling `createMediaElementSource` twice on the same element** —
   throws; use WeakMap caching
3. **Routing Howler through Web Audio for playback** — breaks MediaSession
   binding
4. **Forgetting to prime AudioContext on user gesture** — analyzer
   shows zeros despite audible playback
5. **Unregistering MediaSession action handlers on pause** — hardware
   Play key fails to resume
6. **Putting metadata + handlers + position in the same effect** —
   wastes work, can cause UI flicker
7. **Setting position state with NaN duration** — some browsers throw;
   wrap in try/catch
8. **Using `window.dispatchEvent` for cross-tab coordination** — only
   works same-tab; use `BroadcastChannel`
9. **Creating AudioContext on import** — silently breaks SSR; create
   lazily on first need
10. **Passing fresh handler closures every render** — re-registers every
    render; useCallback or accept the cost in the dual-effect pattern

## Quick reference: the minimal correct setup

**Full code:** `~/.claude/skills/web-audio-howler/examples/audio-engine.example.ts`
— Howler instantiation with `html5: true`, lazy `AudioContext`, WeakMap
caching of `MediaElementAudioSourceNode`, `AnalyserNode` attachment,
gesture-based priming.
