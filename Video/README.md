# Video

## message.mp4 — PLACEHOLDER, but a real clip

Stock footage standing in for the real video message. **Pexels 4962724**, by
Tima Miroshnichenko: a woman filming herself at home against a brick wall.
Free for commercial use under the Pexels Content License, no attribution
required. The original is 1080x1920, 18.1s, 5.4 MB.

What ships here is that clip centre-cropped from 9:16 to the 2:3 the frame
uses, scaled to 720x1080 and re-encoded at CRF 27 with `+faststart` — **811 KB**.

```bash
ffmpeg -i source.mp4 -vf "crop=1080:1620:0:150,scale=720:1080" -an -c:v libx264 -preset slow -crf 27 -pix_fmt yuv420p -movflags +faststart Video/message.mp4
```

**It has no audio.** The source is silent, so playing it ducks the ambient bed
for nothing. That is still the correct behaviour — a real video message will
have a voice on it — but it is worth knowing before you judge the interaction.

It also reads slightly as a content creator rather than a parent: there is a
DSLR in the foreground of the shot. Fine for review, worth replacing.

`Images/Video Poster.jpeg` is a frame from this clip at 8s, so the frame does
not change character the moment someone presses play. Regenerate it alongside
any new clip:

```bash
ffmpeg -ss 8 -i Video/message.mp4 -frames:v 1 -q:v 4 "Images/Video Poster.jpeg"
```

`Images/Video.jpeg` (Pexels 6248451) was the previous poster and is now unused.
Left in place rather than deleted, in case it is wanted elsewhere.

## What a replacement needs

- **Portrait.** The frame is 2:3 and the video is `object-fit: cover`, so
  anything landscape gets cropped hard down the sides. A phone recording at
  1080x1620 is ideal; 1080x1920 crops cleanly with the command above.
- **Short.** Under a minute. This illustrates the product, it is not the product.
- **H.264 + AAC in an .mp4** with `-movflags +faststart`, so it starts before
  the whole file arrives. That covers every current browser.
- **Its own poster**, regenerated from the new clip.
- **Licensed**, and if it shows a real person, with their permission. A stock
  model appearing as a parent recording a message for a child is permitted by
  the Pexels licence but is a decision worth making deliberately.

## Behaviour, for reference

The whole frame plays and pauses, and there is a small explicit control under
the left end of the scrubber. The badge in the middle shows one state at a
time — play when paused, pause on hover while playing — so there is never a
play and a pause on screen together.

Playing it fades the ambient bed down; pausing, finishing, or scrolling the row
out of view fades it back in. Only one thing plays at a time across the page,
so starting the video pauses any voice note and the other way round. See
`Audio/README.md`.

Serving over `file://` will not let the timeline seek — media scrubbing needs
HTTP range requests. `serve.ps1` in the project root handles them for local
preview.
