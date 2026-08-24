# Audio

Two separate things live here: the ambient bed behind the whole page, and the
recordings that play in the "Your actual voice" row.

## ambient.mp3 — the bed

**"Documentary"** — piano-led, nostalgic, slow. Sourced from Pixabay (track
507827), free for commercial use under the Pixabay Content License, no
attribution required.

Currently **938 KB**: 80 seconds, mono, 96 kbps. It was 4.8 MB before, and the
size was not the only problem — the original ran 2:34 and faded out to near
silence at the end while starting at full level, so looping it dropped the
music out and slammed it back every pass.

What is in place now is a proper loop cut from the sustained middle of the
track (40s to 120s), with the last four seconds crossfaded into the four
seconds that lead into the start. The join is inaudible.

`ambient.original.mp3` is the untouched 4.8 MB source, kept so the loop can be
recut. It is gitignored and is not deployed. To rebuild:

```bash
ffmpeg -y -i Audio/ambient.original.mp3 -filter_complex "[0:a]atrim=start=40:end=116,asetpts=N/SR/TB[body];[0:a]atrim=start=116:end=120,asetpts=N/SR/TB[tail];[0:a]atrim=start=36:end=40,asetpts=N/SR/TB[head];[tail][head]acrossfade=d=4:c1=tri:c2=tri[seam];[body][seam]concat=n=2:v=0:a=1[out]" -map "[out]" -ac 1 -c:a libmp3lame -b:a 96k Audio/ambient.mp3
```

To swap the track entirely, replace `ambient.mp3` and nothing else changes —
the path is already wired in `index.html`. Keep it looping, quiet, and
licensed for commercial use.

## voice-01/02/03.mp3 — PLACEHOLDERS

**These are not voice recordings.** They are three excerpts of the same Pixabay
piano track, cut to 0:42, 1:08 and 0:29 so the player has something with real
durations to run against. Replace all three with the actual recordings.

The player reads them from the `VOICE` list near the foot of `index.html`:

```js
const VOICE = [
  {src: 'Audio/voice-01.mp3', label: 'Voice note 01', length: '00:42', cover: 'Images/Voice.jpeg'},
  {src: 'Audio/voice-02.mp3', label: 'Voice note 02', length: '01:08', cover: ''},
  ...
];
```

- `label` shows in the player. The titles are placeholders too — "Voice note 01"
  is a holding line, not copy.
- `length` only covers the moment before the file's own metadata loads, so keep
  it roughly honest but it does not have to be exact.
- `cover` is **optional**. Give it an image path and you get a square card with
  the transport on the ground beneath it. Leave it empty and there is no card at
  all: the brand red fills the whole player, cover area and transport together,
  as one field carrying the title in the display serif. The waveform and the
  button strokes invert to paper in that state, and the deck's own title line
  stands down, so the title is never printed twice.

  Short holding names like "Voice note 02" leave a lot of air in the red field.
  A real title runs to two or three lines and fills it properly.

Mono at 64 kbps is plenty for speech. Three files is what the row is built for;
adding or removing entries in `VOICE` works without touching anything else — the
`01 / 03` counter reads its total from the list.

### Transcripts

`script` is an optional list of cues, one line each, with `t` in seconds:

```js
script: [
  {t: 0,  line: 'Children forget how a parent sounds'},
  {t: 7,  line: 'long before they forget what a parent looked like.'}
]
```

The quote-bubble control opens the panel over the cover and the lines track
along with playback, dimming everything but the one currently being spoken.
Two grounds, picked automatically: over artwork the picture blurs back and the
type goes paper; with no artwork there is nothing to blur, so the panel turns
that area off-white with the deep red on top. A track with no `script` disables
the control.

**The transcript text is placeholder.** The lines are lifted from copy already
on this page rather than invented, precisely so nothing there reads as finished
writing. Replace all of it.

Cue times are hand-set. If you end up with many recordings, generating them from
a transcription service and dropping the result straight into this shape is the
obvious path.

### The waveform is drawn, not measured

The bars are generated from a hash of the file path, so a given recording always
gets the same shape and no two look alike. They are **not** the real peaks of the
audio.

Reading real peaks means fetching and decoding each file in full up front, which
is exactly what `preload="metadata"` is there to avoid — roughly 1 MB of
downloads before anyone has pressed play. If you want true waveforms it is worth
doing, but do it lazily on first play, or precompute the peaks at build time and
ship them as a short array of numbers alongside each track.

## silence.wav

3 seconds of silence, the fallback `<source>` on the ambient element, so the
nav toggle still behaves if `ambient.mp3` is ever missing.

## Behaviour, for reference

The bed never cuts. Every transition — the visitor's toggle, a recording
starting, scrolling away from the section — runs through a 400 ms fade in both
directions, and the fade lands even if the tab is throttled mid-way.

Playing a voice note or the video message holds the bed down; pausing it, or
scrolling the row out of view, hands it back. Holds are tracked as a set, so
two players can never release each other's.

Browsers block audio that starts on its own, so the toggle always begins in the
**off** state. The nav toggle is hidden below 1024px, which is a known gap: a
visitor who turns sound on with a keyboard or a wide window cannot turn it off
again on a phone.
