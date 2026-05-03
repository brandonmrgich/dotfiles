// Example for ~/.claude/skills/nextjs-app-router/SKILL.md
// SSR-correct theme: server component reads cookie + Sec-CH-Prefers-Color-Scheme on first paint.

// app/layout.tsx
import { cookies, headers } from "next/headers"

export default async function RootLayout({ children }) {
  const cookieStore = cookies()
  const themeCookie = cookieStore.get("theme")?.value
  const colorSchemeHeader = headers().get("sec-ch-prefers-color-scheme")
  const theme = themeCookie ?? colorSchemeHeader ?? "light"

  return (
    <html className={theme === "dark" ? "dark" : ""}>
      <body>
        <ThemeProvider ssrInitialTheme={theme}>
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
