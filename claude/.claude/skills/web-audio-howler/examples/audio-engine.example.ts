// Example for ~/.claude/skills/web-audio-howler/SKILL.md
// Minimal correct setup: Howler instantiation with html5:true, lazy
// AudioContext, WeakMap source caching, AnalyserNode attachment, and
// gesture-based AudioContext priming.

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
