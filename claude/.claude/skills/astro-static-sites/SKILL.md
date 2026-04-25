---
name: astro-static-sites
description: Astro framework specialist for static and mostly-static sites including marketing landing pages, documentation sites, and content-driven sites. Covers the Islands Architecture (selective hydration via client:* directives), content collections (type-safe markdown/MDX), Astro components (.astro files), integrations (React, Vue, Svelte, Tailwind, MDX, sitemap), the build pipeline (static vs hybrid vs server output), partial hydration directives (client:load, client:idle, client:visible, client:media, client:only), data fetching at build time vs request time, deployment targets (Vercel, Netlify, Cloudflare, static hosts), and View Transitions API integration. Trigger when the prompt or files in scope reference any of: Astro, .astro files, astro.config.mjs, astro.config.ts, content collections, defineCollection, getCollection, getEntry, client:load, client:idle, client:visible, client:media, client:only, Astro.props, Astro.glob, Astro.url, Astro.request, getStaticPaths, integrations directory, @astrojs/, MDX in Astro context, Astro middleware, View Transitions, ViewTransitions component. Do NOT trigger for generic markdown/MDX questions unrelated to Astro framework features. Do NOT trigger for static site questions when the framework is Next.js, Gatsby, or other.
---

# Astro Static Sites Specialist

Domain expert on the Astro framework. Astro is best for content-heavy,
mostly-static sites where shipping minimal JavaScript is the goal.

## The mental model

Astro components (`.astro` files) render to HTML at build time by default.
Zero JavaScript ships to the client unless you explicitly opt in via a
`client:*` directive. This is the "Islands Architecture" — interactive
components are isolated islands in a sea of static HTML.

```astro
---
// Frontmatter runs at build time (Node.js)
import HeavyChart from '../components/HeavyChart.jsx'
const data = await fetch('https://api.example.com/data').then(r => r.json())
---

<html>
  <body>
    <h1>Static at build time</h1>

    <!-- This component is interactive only when JS loads -->
    <HeavyChart client:load data={data} />
  </body>
</html>
```

## Hydration directives (use the lightest one that works)

| Directive | When it hydrates | Use case |
|---|---|---|
| `client:load` | Immediately on page load | Above-the-fold interactivity |
| `client:idle` | When browser is idle (`requestIdleCallback`) | Below-the-fold, non-critical |
| `client:visible` | When component scrolls into view | Lazy-load heavy components |
| `client:media={query}` | When media query matches | Mobile-only or desktop-only widgets |
| `client:only={"react"}` | Skip SSR, render only on client | Browser-only libs (charts, maps) |

**Default to `client:visible`** for anything below the fold. Default to
`client:load` only when the component must be interactive instantly.

## Content collections (the killer feature)

Type-safe content with frontmatter validation:

```ts
// src/content/config.ts
import { defineCollection, z } from 'astro:content'

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    publishDate: z.date(),
    author: z.string(),
    tags: z.array(z.string()),
  }),
})

export const collections = { blog }
```

Then queries are typed:

```ts
import { getCollection, getEntry } from 'astro:content'

const allPosts = await getCollection('blog')
const post = await getEntry('blog', 'my-first-post')
// post.data is fully typed from the schema
```

Content collections work for `.md`, `.mdx`, `.json`, `.yaml`, `.yml`. Use
them for blogs, docs, project listings, anything content-shaped.

## Build output modes

```js
// astro.config.mjs
export default defineConfig({
  output: 'static',  // default — all HTML at build time
  // OR
  output: 'hybrid',  // static by default, opt-in to SSR per page
  // OR
  output: 'server',  // SSR by default, opt-in to static per page
})
```

For marketing/landing pages: `static` (default).
For sites with a few dynamic routes: `hybrid` with `export const prerender = false` on the dynamic pages.
For mostly-dynamic sites: probably use Next.js instead.

## Data fetching

At build time (default for static):

```astro
---
const data = await fetch('https://api.example.com/data').then(r => r.json())
---
```

At request time (hybrid/server with `prerender = false`):

```astro
---
export const prerender = false
const data = await fetch('https://api.example.com/data').then(r => r.json())
---
```

The same `fetch` call — what changes is when the page renders.

## Common integrations

```js
// astro.config.mjs
import { defineConfig } from 'astro/config'
import react from '@astrojs/react'
import tailwind from '@astrojs/tailwind'
import mdx from '@astrojs/mdx'
import sitemap from '@astrojs/sitemap'

export default defineConfig({
  integrations: [
    react(),       // .jsx/.tsx components
    tailwind(),    // Tailwind CSS
    mdx(),         // .mdx files
    sitemap(),     // sitemap.xml
  ],
})
```

Install via:
```
pnpm astro add react tailwind mdx sitemap
```

The `astro add` command edits config and installs deps in one step.

## View Transitions

Built-in support for smooth page transitions:

```astro
---
import { ViewTransitions } from 'astro:transitions'
---

<html>
  <head>
    <ViewTransitions />
  </head>
  <body>
    <main transition:name="content">
      <slot />
    </main>
  </body>
</html>
```

Persistent elements (audio players, header nav) survive navigations:

```astro
<header transition:persist>
  <!-- not re-rendered on nav -->
</header>
```

## Tooling exception watchlist

Astro pulls a long dependency chain. Common pinning sources include:

- `@astrojs/check` → `@astrojs/language-server` → `volar-service-yaml` →
  `yaml-language-server` → `yaml`

If the host project pins `yaml` or similar via overrides, that's why.

## Common pitfalls

1. **Defaulting to `client:load`** when `client:visible` would work —
   ships JS unnecessarily
2. **Importing React components without an integration** — must be
   installed via `pnpm astro add react`
3. **Using `client:only` when SSR would work** — loses progressive
   enhancement benefits
4. **Content collection schema drift** — schema lives in `src/content/config.ts`;
   when frontmatter and schema diverge, the build fails (good!) but only
   if you actually validate
5. **Trying to use Next.js patterns** — no `getServerSideProps`, no
   `getStaticProps`; data fetching is just top-level `await` in frontmatter
6. **`Astro.glob` for content** — deprecated; use content collections instead
7. **Forgetting `astro:content` and `astro:transitions` are virtual modules** —
   these imports are runtime, not from npm
8. **Mixing build-time and request-time data in the same component without
   `prerender` config** — leads to confusing behavior

## When NOT to use Astro

- Apps with significant client-side state (use Next.js / Remix / SvelteKit)
- Real-time / WebSocket-heavy interfaces
- Anything where most of the UI is interactive

Astro is the right choice when "mostly static, some interactive widgets"
describes the site.

## What you must never do

- Do not advise `getServerSideProps` patterns — that's Next.js Pages Router
- Do not skip hydration directives entirely on interactive components —
  they won't work
- Do not advise using `Astro.glob` for new code — content collections
  superseded it
