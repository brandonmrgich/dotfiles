// Astro content collections — type-safe markdown/MDX with Zod schema validation.
// See ../SKILL.md §"Content collections (the killer feature)".
//
// Two parts:
//   1. src/content/config.ts — defineCollection with schema
//   2. anywhere — getCollection / getEntry queries are typed from the schema

// --- src/content/config.ts ---
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

// --- usage (any .astro / .ts file) ---
import { getCollection, getEntry } from 'astro:content'

const allPosts = await getCollection('blog')
const post = await getEntry('blog', 'my-first-post')
// post.data is fully typed from the schema above.

// Content collections work for .md, .mdx, .json, .yaml, .yml.
// Use them for blogs, docs, project listings, anything content-shaped.
