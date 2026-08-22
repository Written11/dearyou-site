# Written

Landing page for **Written** — a private vault where parents write letters, record their
voice, and keep photographs for their children, sealed until they decide it is time.

> For the words that cannot wait.

This repository holds the marketing site only. Its job is to introduce the product and
funnel visitors to the app on the store.

## Contents

| Path | What it is |
| --- | --- |
| `Written Landing.html` | The landing page — a single self-contained file |
| `Images/` | Photography used on the page |
| `Illustrations/` | Frame and ornament SVGs |
| `Logo/` | Logotype, logo mark, icon, and favicons |
| `written-website-flow.pdf` | Reference: the intended page flow |

## Page structure

1. **Hero** — "The things you would say if you could sit down together" + waitlist capture
2. **Trust pillars** — you hold the key · sealed until you say · nothing expires · someone you trust
3. **How it works** — write it while you can → seal it in the vault → release it when it is time
4. **What you can leave** — letters, voice, video, photographs
5. **Why now** — "Distance is not the same as absence"
6. **Pricing** — Open (free) · Vault · Forever
7. **Voices** — quotes from early families
8. **Waitlist** — "Say it now. Give it to them later."

## Brand notes

The voice is intimate but unsentimental. Sentences breathe. No exclamation marks, no
"unlock", no "boost", no "your journey". The reader is *you*; their child is *them*.
Photography is of hands and objects, never faces, in late-afternoon or candle light.

Nothing on the page should imply efficiency, optimisation, or speed. People come to
Written to slow down.

## Status

Pre-launch. The page collects waitlist emails ahead of opening in early 2027.

## Working on it locally

The page is a single HTML file with no build step. Open it in a browser:

```bash
# macOS
open "Written Landing.html"

# Windows
start "" "Written Landing.html"
```

## Known issues

- Several `<image-slot>` elements still point at `blob:null/…` URLs left over from the
  design-canvas export. They need repointing at the real files in `Images/`,
  `Illustrations/`, and `Logo/` before the page is deployed.
- In-page anchors (`#how`, `#pricing`, `#waitlist`) currently carry absolute
  `file:///C:/…` prefixes from the same export and should be reduced to bare fragments.
