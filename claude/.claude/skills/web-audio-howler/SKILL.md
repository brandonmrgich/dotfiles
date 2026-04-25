---
name: web-audio-howler
description: Web audio playback specialist covering Howler.js (the cross-browser audio library), the Web Audio API integration patterns, the OS-level MediaSession API for lock-screen and hardware-key controls, and the dual-path architecture needed when combining Howler playback with Web Audio analysis (analyzer/visualizer). Covers the html5-vs-buffer Howler mode tradeoff (html5:true required for MediaSession on iOS), the createMediaElementSource one-per-element constraint and WeakMap caching pattern, AudioContext priming requirements (user gesture to resume), MediaSession metadata + action handlers + position state, the identity-vs-position effect split for MediaSession ownership hooks, and cross-app/cross-tab playback ownership coordination via BroadcastChannel. Trigger when the prompt or files in scope reference any of: Howler, howler.js, Howl, Web Audio API, AudioContext, MediaElementAudioSourceNode, createMediaElementSource, AnalyserNode, MediaSession, navigator.mediaSession, mediaSession.metadata, mediaSession.setPositionState, MediaMetadata, action handlers (play/pause/seekto/seekbackward/seekforward), html5:true, html5:false, audio playback, audio visualizer, audio analyzer, audio waveform, audio engine, lock screen audio, hardware media keys, OS audio integration. Do NOT trigger for generic audio file format questions unrelated to playback.
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
Audio file (MP3/WAV/etc)
       ↓
   Howler.js (html5: true)
       ↓
   <audio> element (HTMLMediaElement)
       ↓ (browser playback path)
   ┌───┴───┐
   ↓       ↓
 Speakers  Web Audio API
           ↓
       AudioContext
           ↓
       MediaElementAudioSourceNode
           ↓
       AnalyserNode
           ↓
       destination (silent — playback already happening via <audio>)
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
sources per element using `WeakMap`:

```ts
const sourceCache = new WeakMap<HTMLMediaElement, MediaElementAudioSourceNode>()

function getOrCreateSource(audio: HTMLMediaElement, ctx: AudioContext) {
  let source = sourceCache.get(audio)
  if (!source) {
    source = ctx.createMediaElementSource(audio)
    sourceCache.set(audio, source)
  }
  return source
}
```

`WeakMap` lets the entry be garbage-collected when the audio element is.

## AudioContext priming

Browsers require a user gesture to start an `AudioContext`. The pattern:

```ts
let audioContext: AudioContext | null = null

export function getAudioContext(): AudioContext {
  if (!audioContext) {
    audioContext = new AudioContext()
  }
  return audioContext
}

// Call this from a click/tap/keydown handler the first time
export async function primeAudioContext() {
  const ctx = getAudioContext()
  if (ctx.state === 'suspended') {
    await ctx.resume()
  }
}
```

If the analyzer's `AudioContext` isn't primed, visualizations show all
zeros even though playback is audible (because Howler's `<audio>` element
plays independently of the suspended context).

## MediaSession integration

Three concerns, three separate effects:

### 1. Identity (metadata + handlers)

Set when the track changes or the available actions change:

```ts
useEffect(() => {
  if (!metadata) {
    navigator.mediaSession.metadata = null
    navigator.mediaSession.playbackState = 'none'
    return
  }

  navigator.mediaSession.metadata = new MediaMetadata({
    title: metadata.title,
    artist: metadata.artist,
    album: metadata.album,
    artwork: [{ src: metadata.artwork, sizes: '512x512', type: 'image/png' }],
  })

  navigator.mediaSession.setActionHandler('play', handlers.onPlay)
  navigator.mediaSession.setActionHandler('pause', handlers.onPause)
  navigator.mediaSession.setActionHandler('seekto', handlers.onSeek)
  navigator.mediaSession.setActionHandler('seekbackward', handlers.onSeekBack)
  navigator.mediaSession.setActionHandler('seekforward', handlers.onSeekForward)

  navigator.mediaSession.playbackState = isPlaying ? 'playing' : 'paused'
}, [metadata, handlers, isPlaying])
```

**Critical: don't unregister handlers on pause.** The hardware Play key
must reach `onPlay` even when paused. Only clear when the track unloads
or the component unmounts.

### 2. Position (separate effect, ticks frequently)

```ts
useEffect(() => {
  if (!duration) return
  try {
    navigator.mediaSession.setPositionState({
      duration,
      position: Math.min(position, duration),
      playbackRate: 1.0,
    })
  } catch {
    // Some browsers throw when duration is 0 or invalid; swallow
  }
}, [position, duration])
```

This is what renders the lock-screen scrubber and enables drag-to-seek.

**Why two effects:** position updates frequently (~4Hz typically). If
you put position in the same effect as metadata + handlers, you re-register
all handlers 4 times a second, which is wasteful and on some browsers
causes flicker.

### 3. Cleanup

When the track unloads or component unmounts, clear EVERYTHING:

```ts
return () => {
  navigator.mediaSession.metadata = null
  navigator.mediaSession.playbackState = 'none'
  // Don't bother unregistering handlers — they'll never be called
  // because metadata is null
}
```

## Cross-app / cross-tab ownership

If multiple tabs or apps want to coordinate "only one plays at a time,"
`BroadcastChannel` is the right primitive (NOT `window.dispatchEvent` —
that's same-tab only):

```ts
const channel = new BroadcastChannel('audio-playback')

// When a tab starts playing:
channel.postMessage({ type: 'PLAYBACK_STARTED', appId: 'my-app' })

// Other tabs listen and pause themselves:
channel.onmessage = (e) => {
  if (e.data.type === 'PLAYBACK_STARTED' && e.data.appId !== 'my-app') {
    pauseLocalPlayback()
  }
}
```

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

```ts
// audio-engine.ts
import { Howl } from 'howler'

let audioContext: AudioContext | null = null
const sourceCache = new WeakMap<HTMLMediaElement, MediaElementAudioSourceNode>()

export function getAudioContext() {
  if (!audioContext) audioContext = new AudioContext()
  return audioContext
}

export function createTrack(src: string) {
  return new Howl({ src: [src], html5: true })  // html5 critical
}

export function attachAnalyser(audio: HTMLMediaElement) {
  const ctx = getAudioContext()
  let source = sourceCache.get(audio)
  if (!source) {
    source = ctx.createMediaElementSource(audio)
    sourceCache.set(audio, source)
  }
  const analyser = ctx.createAnalyser()
  source.connect(analyser)
  analyser.connect(ctx.destination)
  return analyser
}

export async function primeOnGesture() {
  const ctx = getAudioContext()
  if (ctx.state === 'suspended') await ctx.resume()
}
```

## What you must never do

- Do not advise `html5: false` for production audio with OS integration
- Do not advise routing Howler through Web Audio for playback (kills
  MediaSession on iOS)
- Do not advise `createMediaElementSource` without WeakMap caching
- Do not advise creating AudioContext at module load time
- Do not advise `window.dispatchEvent` for cross-tab playback coordination
