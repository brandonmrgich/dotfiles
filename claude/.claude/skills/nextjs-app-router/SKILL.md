---
name: nextjs-app-router
description: "Use when the prompt or files in scope reference Next.js 13+ App Router: server / client components, 'use client' / 'use server' directives, server actions, route handlers, middleware, app/ routing files (layout.tsx / page.tsx / loading.tsx / error.tsx / not-found.tsx), generateMetadata, generateStaticParams, Request/Data/Full Route/Router Cache layers, revalidatePath / revalidateTag / unstable_cache / router.refresh, cookies / headers / redirect / notFound, useFormStatus / useFormState / useOptimistic, parallel and intercepting routes, route groups, dynamic and catch-all segments, BFF proxy under app/api/, skipHydration / persist.rehydrate / hydration mismatch, next.config.{js,mjs}. Do NOT trigger for Pages Router (pages/) or for generic React unrelated to framework features. Do NOT trigger for a specific monorepo's BFF wiring — defer to project-local specialists (music-platform-api, music-platform-architecture). DO trigger for core framework API questions even inside a monorepo."
---

# Next.js App Router Specialist

Domain expert on the Next.js 13+ App Router. Activates alongside any agent
role to provide framework-specific guidance.

## The mental model that matters most

Server components are the default. Client components are an opt-in via
`"use client"` at the top of a file. Once a file is marked `"use client"`,
every component imported into it becomes a client component too — the
boundary is one-directional from the entry point.

A server component CAN render a client component as a child. A client
component CANNOT render a server component as a child *except* via the
`children` prop pattern.

## Server vs client component decision tree

Use a server component when:
- Fetching data (always prefer this)
- Accessing backend resources directly (DB, filesystem, internal APIs)
- Keeping sensitive info on the server (API keys, tokens)
- Reducing client bundle size
- The component does not need interactivity, state, or browser APIs

Use a client component when:
- You need useState, useEffect, useReducer, or other React hooks
- You need event handlers (onClick, onChange, onSubmit)
- You need browser APIs (window, localStorage, navigator)
- You need third-party libraries that depend on the above

The default should be server. Push the `"use client"` boundary as deep
into the leaf components as possible.

## Server actions

Server actions are async functions marked with `"use server"` that can be
called from both server and client components. They run on the server.

```ts
// app/actions.ts
"use server"
export async function updateRelease(formData: FormData) {
  // runs server-side, can hit DB directly
  revalidatePath("/releases")
}
```

Use server actions for:
- Form submissions (works without client JavaScript)
- Mutations that need to invalidate cached data
- Operations where you'd otherwise create a route handler just to receive a POST

Don't use server actions for:
- Read operations (use server components instead)
- Anything that needs to return data to a non-React client (use a route handler)

## Route handlers vs server actions

| Need | Use |
|---|---|
| External API endpoint | Route handler (`app/api/.../route.ts`) |
| Form submission from your own UI | Server action |
| Webhook receiver | Route handler |
| Mutation tied to revalidation | Server action |
| Public data API | Route handler |

## The four caching layers (the #1 source of "why isn't my data updating" bugs)

| Cache | Scope | Lifetime | Invalidation |
|---|---|---|---|
| Request Memoization | Single request, server | Per-request | Automatic |
| Data Cache | All requests, server | Persistent | revalidate, revalidateTag, revalidatePath |
| Full Route Cache | All requests, server | Until rebuild | revalidatePath, route deploys |
| Router Cache | Per-user, client | Session | router.refresh, hard navigation |

When data isn't updating after a mutation:
1. Did you call `revalidatePath` or `revalidateTag` from the server action?
2. Is the route segment dynamic or static? Static routes need explicit revalidation.
3. Is the client Router Cache holding stale data? `router.refresh()` busts it.

## Form patterns

```tsx
// Modern form pattern with useFormState + useFormStatus
"use client"
import { useFormState, useFormStatus } from "react-dom"
import { updateRelease } from "./actions"

function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>{pending ? "Saving..." : "Save"}</button>
}

export function ReleaseForm({ release }) {
  const [state, action] = useFormState(updateRelease, { error: null })
  return (
    <form action={action}>
      {/* fields */}
      <SubmitButton />
      {state.error && <p>{state.error}</p>}
    </form>
  )
}
```

This pattern works without client JS (server actions degrade gracefully)
and integrates cleanly with form state machine patterns.

## BFF (backend-for-frontend) proxy pattern

A common monorepo pattern: an admin Next.js app proxies to a separate API
to avoid CORS and centralize cross-cutting concerns.

```
Browser
  ↓ same-origin
Admin Next.js (apps/admin)
  ↓ /api/admin/* route handlers (server-side)
Upstream API (apps/api)
```

Why this pattern:
- Browser only sees same-origin requests — no CORS, cookies survive
- Server-side proxy can add auth, tracing, retries
- Upstream API stays focused on data, not browser concerns

Implementation pattern:
1. `app/api/admin/<resource>/route.ts` — 5-line file that delegates to a
   shared proxy helper
2. Shared helper forwards method, path, query, body, cookies, headers
3. Client components call same-origin `/api/admin/...` via typed helpers

If a project uses this pattern, it likely has a project-local specialist
that documents the specific helper functions and conventions. Defer to
those.

## Hydration with persisted client state

When using Zustand persist (or similar) with SSR, hydration mismatches
happen because the server emits empty state while the client emits
restored-from-localStorage state.

The fix: `skipHydration: true` on the persist config prevents auto-hydration;
manual `persist.rehydrate()` in a client `useEffect` ensures the first paint
matches the server, then state restores after.

**Full code:** `~/.claude/skills/nextjs-app-router/patterns/hydration.example.tsx`
— persisted Zustand with skipHydration + manual rehydrate.

## Theme via cookie (SSR-correct)

Avoid `next/script` theme bootstrap (triggers React 19 warnings). Use a
cookie + `Sec-CH-Prefers-Color-Scheme` pattern: a server component reads
both in `app/layout.tsx` and emits the correct theme class on first paint.
A client `ThemeProvider` then syncs cookie + localStorage on changes. No
client-side script in the React tree.

**Full code:** `~/.claude/skills/nextjs-app-router/patterns/theme-cookie.example.ts`
— SSR-correct theme via cookie + Sec-CH-Prefers-Color-Scheme.

## Common pitfalls

1. **Importing server-only code into client components** — install and use
   `server-only` package to fail loudly at build time
2. **`"use client"` on layout** — turns the entire subtree into client
   components, bloats bundle
3. **Forgetting `revalidatePath` after server action mutations** — UI
   shows stale data
4. **Using `cookies()` or `headers()` in static routes** — implicitly
   makes the route dynamic; surprising bundle/perf changes
5. **Returning Date objects from server components** — must serialize;
   pass strings or numbers to client components
6. **Hydration mismatches** from server-rendered timestamps, random IDs,
   `Math.random()`, or persisted client stores without `skipHydration`
7. **Treating `loading.tsx` as a global loading state** — it's per-segment;
   nest carefully
8. **Forgetting `generateStaticParams`** for dynamic routes that should
   be static
9. **Using `router.push()` expecting fresh data** — Router Cache returns
   stale; use `router.refresh()` first
10. **Mixing `"use client"` and `"use server"` in the same file** — illegal

## Streaming and Suspense

`loading.tsx` automatically wraps the page in a Suspense boundary. For
finer control, use `<Suspense>` directly to stream parts of a page while
others load.

```tsx
<Suspense fallback={<Skeleton />}>
  <SlowDataComponent />
</Suspense>
```

## What you must never do

- Do not advise Pages Router patterns (getServerSideProps, getStaticProps)
  for App Router code.
- Do not recommend `useEffect` for data fetching in server components
  (server components don't run `useEffect`).
- Do not advise calling server actions from a route handler — call the
  underlying logic directly.
- Do not advise project-specific BFF helper patterns; defer to project-local
  specialists if they exist.
