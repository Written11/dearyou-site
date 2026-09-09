# DearYou marketing site — handover

This document is for the new owner of this repository. It explains what the
project is, how ownership moves across, and how to run and publish the site.

## What this is

The public marketing site for DearYou. It is a single self-contained page,
`index.html`, with one stylesheet (`tokens.css`) and its media in `Images/`,
`Illustrations/`, `Logo/`, `Audio/`, and `Video/`. There is no build step and
no server code: the browser opens the HTML directly.

It is published with **GitHub Pages**, so pushing to the `main` branch is what
deploys the live site.

## Transferring ownership (done once, by the current owner)

Ownership of a GitHub project moves by transferring the repository itself. The
current owner does this from GitHub:

1. Open the repository on GitHub, then go to **Settings → General**.
2. Scroll to the **Danger Zone** and choose **Transfer ownership**.
3. Enter the new owner's GitHub username or organisation and confirm.
4. The new owner receives an email and **accepts** the transfer.

Everything comes across in the move: the code, the full history, and the
settings. Nothing needs to be re-uploaded.

## After the transfer (done by the new owner)

1. **Turn Pages back on if needed.** Go to **Settings → Pages** and confirm the
   source is the `main` branch. GitHub usually keeps this, but check it.
2. **Note the new address.** With no custom domain, the site is served at
   `https://<new-account>.github.io/<repository-name>/`. It changes to reflect
   the new account name; there is nothing to renew or pay for.
3. **Update the local clone's remote** (only if you already cloned it before the
   transfer):
   ```bash
   git remote set-url origin https://github.com/<new-account>/<repository-name>.git
   ```

## Running it locally

No build, no dependencies. Open the page directly:

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

Edit `index.html` (or `tokens.css`, or swap a file in the media folders), then:

```bash
git add -A
git commit -m "Describe the change"
git push
```

GitHub Pages redeploys within a minute or two. `push-to-github.ps1` is an
optional helper that walks first-time setup; day to day, the three commands
above are all you need.

## What is in the repository

| Path | What it is |
| --- | --- |
| `index.html` | The live site — one self-contained page |
| `tokens.css` | The design tokens (colour, type, spacing) the page reads from |
| `Images/`, `Illustrations/`, `Logo/` | Photography, ornaments, and brand marks |
| `Audio/`, `Video/` | The ambient bed, voice samples, and the message clip |
| `serve.ps1`, `push-to-github.ps1` | Optional local-run and first-push helpers |

## Notes

- There are no secrets, API keys, or passwords in this repository, so nothing
  needs to be rotated on handover.
- No custom domain or branded email is configured here; the site lives on the
  GitHub Pages address above.
