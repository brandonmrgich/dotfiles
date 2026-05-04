---
name: nextjs-app-router
class: specialist
description: "Use when the prompt or files in scope reference Next.js 13+ App Router: server / client components, 'use client' / 'use server' directives, server actions, route handlers, middleware, app/ routing files (layout.tsx / page.tsx / loading.tsx / error.tsx / not-found.tsx), generateMetadata, generateStaticParams, Request/Data/Full Route/Router Cache layers, revalidatePath / revalidateTag / unstable_cache / router.refresh, cookies / headers / redirect / notFound, useFormStatus / useFormState / useOptimistic, parallel and intercepting routes, route groups, dynamic and catch-all segments, BFF proxy under app/api/, skipHydration / persist.rehydrate / hydration mismatch, next.config.{js,mjs}. Do NOT trigger for Pages Router (pages/) or for generic React unrelated to framework features. Do NOT trigger for a specific monorepo's BFF wiring — defer to project-local specialists (music-platform-api, music-platform-architecture). DO trigger for core framework API questions even inside a monorepo."
---

# Next.js App Router Specialist

Domain expert on Next.js 13+ App Router. Co-activates with agent roles.

## Mental model

Server components are the default; `"use client"` opts in. Once a file
is marked `"use client"`, every component it imports becomes client too
— the boundary is one-directional. A server component can render a
client child; a client component can render a server child only via
the `children` prop. Push `"use client"` as deep toward leaves as
possible.

## Server vs client component

| Use server when | Use client when |
|---|---|
| Fetching data (always prefer) | Need `useState` / `useEffect` / hooks |
| DB, filesystem, internal API access | Event handlers (`onClick`, `onChange`) |
| Keeping secrets server-side | Browser APIs (`window`, `localStorage`) |
| No interactivity / state / browser APIs | Third-party libs that need any of the above |

## Server actions

Async functions marked `"use server"`, callable from server or client;
always run server-side.

```ts
// app/actions.ts
"use server"
export async function updateRelease(formData: FormData) {
  revalidatePath("/releases")
}
```

Use for: form submissions (works without client JS), mutations that
invalidate cached data, POST endpoints you'd otherwise hand-roll.
Avoid for: reads (use server components), non-React clients (use a
route handler).

## Route handlers vs server actions

| Need | Use |
|---|---|
| External API endpoint | Route handler (`app/api/.../route.ts`) |
| Form submission from your own UI | Server action |
| Webhook receiver | Route handler |
| Mutation tied to revalidation | Server action |
| Public data API | Route handler |

## The four caching layers

The #1 source of "why isn't my data updating" bugs.

| Cache | Scope | Lifetime | Invalidation |
|---|---|---|---|
| Request Memoization | Single request, server | Per-request | Automatic |
| Data Cache | All requests, server | Persistent | revalidate, revalidateTag, revalidatePath |
| Full Route Cache | All requests, server | Until rebuild | revalidatePath, route deploys |
| Router Cache | Per-user, client | Session | router.refresh, hard navigation |

Stale-data triage: did the action call `revalidatePath` / `revalidateTag`?
Is the segment static (needs explicit revalidation)? Is the client Router
Cache stale (`router.refresh()` busts it)?

## Form patterns

```tsx
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

`useFormState` + `useFormStatus` degrade gracefully (works without
client JS) and integrate cleanly with form state machines.

## BFF (backend-for-frontend) proxy pattern

Common monorepo shape: an admin Next.js app proxies to a separate
upstream API to keep the browser same-origin (no CORS, cookies
survive) and to centralize auth/tracing/retries server-side.

```
Browser → Admin Next.js → /api/admin/* route handlers → Upstream API
```

Implementation: thin `app/api/admin/<resource>/route.ts` files
delegate to a shared proxy helper that forwards method, path, query,
body, cookies, headers. Clients call same-origin `/api/admin/...`
via typed helpers. Project-local specialists own the specific helper
conventions — defer to them.

## Hydration with persisted client state

Zustand persist (or similar) + SSR mismatches: server emits empty
state, client emits restored-from-localStorage state. Fix: set
`skipHydration: true` on the persist config and call
`persist.rehydrate()` from a client `useEffect` so first paint matches
the server, then state restores.

**Full code:** `~/.claude/skills/nextjs-app-router/patterns/hydration.example.tsx`

## Theme via cookie (SSR-correct)

Avoid `next/script` bootstrap (React 19 warnings). Pattern: a server
component in `app/layout.tsx` reads a cookie + `Sec-CH-Prefers-Color-Scheme`
and emits the theme class on first paint; a client `ThemeProvider`
syncs cookie + localStorage on changes. No client script in the tree.

**Full code:** `~/.claude/skills/nextjs-app-router/patterns/theme-cookie.example.ts`

## Common pitfalls

1. **Server-only code imported into clients** — use the `server-only` package to fail at build.
2. **`"use client"` on a layout** — turns the whole subtree client; bloats bundle.
3. **Forgetting `revalidatePath` after a server action mutation** — UI stays stale.
4. **`cookies()` / `headers()` in a static route** — silently makes it dynamic.
5. **Returning Date objects from server components** — must serialize to strings/numbers.
6. **Hydration mismatches** from server-rendered timestamps, random IDs, `Math.random()`, or persisted stores without `skipHydration`.
7. **Treating `loading.tsx` as global** — it's per-segment; nest carefully.
8. **Missing `generateStaticParams`** for dynamic routes meant to be static.
9. **`router.push()` expecting fresh data** — Router Cache stale; `router.refresh()` first.
10. **Mixing `"use client"` and `"use server"` in one file** — illegal.

## Streaming and Suspense

`loading.tsx` wraps the page in Suspense automatically. For finer
control, use `<Suspense>` directly to stream slow parts.

```tsx
<Suspense fallback={<Skeleton />}>
  <SlowDataComponent />
</Suspense>
```

## What you must never do

- Don't advise Pages Router patterns (`getServerSideProps`, `getStaticProps`) on App Router code.
- Don't recommend `useEffect` for data fetching in server components (they don't run effects).
- Don't call server actions from a route handler — call the underlying logic directly.
- Don't advise project-specific BFF helpers; defer to project-local specialists.
