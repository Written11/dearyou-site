# DearYou

Marketing site for **DearYou** — a private vault where parents write letters, record their
voice, and keep photographs for their children, sealed until they decide it is time.

> For the words that cannot wait.

This repository holds the marketing site only. Its job is to introduce the product and
funnel visitors to the app. It is published with GitHub Pages, so a push to `main`
deploys the live site.

New owner? See [HANDOVER.md](HANDOVER.md) for how ownership, hosting, and updates work.

## Contents

| Path | What it is |
| --- | --- |
| `index.html` | The live site — one self-contained page |
| `tokens.css` | The design tokens (colour, type, spacing) the page reads from |
| `Images/` | Photography used on the page |
| `Illustrations/` | Frame and ornament SVGs |
| `Logo/` | Logotype, logo mark, icon, and favicons |
| `Audio/`, `Video/` | The ambient bed, voice samples, and the message clip |
| `serve.ps1`, `push-to-github.ps1` | Optional local-run and first-push helpers |

## Page structure

1. **Hero** — "The things you would say if you could sit down together" + waitlist capture
2. **Trust pillars** — you hold the key · sealed until you say · nothing expires · someone you trust
3. **How it works** — write it while you can, seal it in the vault, release it when it is time
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
DearYou to slow down.

## Working on it locally

The page is a single HTML file with no build step. Open it in a browser:

```bash
# Windows
start "" index.html

# macOS
open index.html
```

Or serve it on a local port (some browsers are stricter about local files):

```powershell
# Windows PowerShell, from this folder
./serve.ps1
```

## Publishing a change

Edit `index.html` (or `tokens.css`, or swap a file in the media folders), then commit and
push to `main`. GitHub Pages redeploys within a minute or two.

```bash
git add -A
git commit -m "Describe the change"
git push
```

## Status

Pre-launch. The page collects waitlist emails ahead of opening.
