// Example for ~/.claude/skills/web-audio-howler/SKILL.md
// MediaSession integration: identity-vs-position effect split, action
// handlers, setPositionState, cleanup, and BroadcastChannel for cross-tab
// playback ownership coordination.

// ---------------------------------------------------------------------------
// 1. Identity effect — metadata + handlers. Runs when track or handlers change.
// ---------------------------------------------------------------------------
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

// Critical: don't unregister handlers on pause. The hardware Play key must
// reach onPlay even when paused. Only clear when track unloads or unmount.

// ---------------------------------------------------------------------------
// 2. Position effect — separate, ticks frequently (~4Hz).
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// 3. Cleanup — when track unloads or component unmounts.
// ---------------------------------------------------------------------------
return () => {
  navigator.mediaSession.metadata = null
  navigator.mediaSession.playbackState = 'none'
  // Don't bother unregistering handlers — they'll never be called
  // because metadata is null
}

// ---------------------------------------------------------------------------
// 4. Cross-tab ownership coordination via BroadcastChannel.
//    NOT window.dispatchEvent (same-tab only).
// ---------------------------------------------------------------------------
const channel = new BroadcastChannel('audio-playback')

// When a tab starts playing:
channel.postMessage({ type: 'PLAYBACK_STARTED', appId: 'my-app' })

// Other tabs listen and pause themselves:
channel.onmessage = (e) => {
  if (e.data.type === 'PLAYBACK_STARTED' && e.data.appId !== 'my-app') {
    pauseLocalPlayback()
  }
}
