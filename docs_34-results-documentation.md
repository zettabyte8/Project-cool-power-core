<!-- docs/34-results-documentation.md -->
# 34 — Documenting Results

How to make a $44 rig's output credible enough to fund on.

## 1. The three rules

1. **Show the blank.** A result without its blank is a rumour.
2. **Show the raw numbers**, not just the fitted line.
3. **Show the failures.** A document with no failures reads as unmeasured.

## 2. Photograph protocol

- Phone in a fixed clamp, same position every run, taped marks on the bench
- A coin or ruler in frame for scale
- A visible clock or the phone's own timestamp in every shot
- Both scale displays every 5 minutes
- Any anomaly — a drip, a bubble, a loose joint — photographed where it happens
- Never re-take a photo after the fact and imply it was during the run

## 3. Data

One CSV per run, 1 Hz: time, feed g, trap g, air flow, slipstream ratio, reservoir °C, arc W, f, notes.

Commit it raw to `/test-data/G1/`. Do not tidy it first.

## 4. Graphs to produce

| Graph | Why it funds |
|---|---|
| f vs arc power, 4 points | Shows the mechanism responds to input. The single most important chart |
| Water balance bar chart, 4 RH values | Proves the machine's real consumable rate |
| Blank vs live, same axes | Proves the signal is not leak |
| Trap mass vs time, live and blank | Shows a straight line, which is what a reviewer looks for |

Plain, axis-labelled, units on both axes, no 3D, no gradients.

## 5. What kills credibility

- Reporting gross water as net
- One run per condition
- No blank
- A single point with a line through it
- Any number with no derivation
- Rounding to look better than the data

## 6. Notebook

Bound, numbered pages, ink, date and time on every entry, no erasing — strike through errors and initial. Photograph each page at the end of the day. A bound notebook is worth more to a reviewer than a spreadsheet.

## 7. Publish

Push results, blanks and CSVs to the repo under the open licence. Public data is harder to dismiss than private data, and it is the thing that gets a program officer to reply.