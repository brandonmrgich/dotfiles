// Example for ~/.claude/skills/nextjs-app-router/SKILL.md
// Persisted Zustand with skipHydration + manual rehydrate in a useEffect.

// store.ts
export const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'my-store',
      skipHydration: true,  // critical
    }
  )
)

// providers.tsx
"use client"
export function Providers({ children }) {
  useEffect(() => {
    useStore.persist.rehydrate()
  }, [])
  return <>{children}</>
}
