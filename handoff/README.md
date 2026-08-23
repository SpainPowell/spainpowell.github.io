# Spain Powell — Brand Identity Handoff (v1.0, Aug 2026)

Personal brand for Spain Powell: data scientist, engineer, systems builder (Costa Mesa, CA).
Direction: **coastal California precision** — warm, sunlit, and human, with the discipline of
routes, models, and runbooks underneath. Never beachy, never corporate, no purple/blue AI tropes.

## Palette (see tokens.css)
| Token | Hex | Role |
|---|---|---|
| ink | #100D0A | page base (dark mode default) |
| graphite | #1C1712 | surfaces / cards |
| bone | #F7EEDF | text on dark; light-mode base |
| driftwood | #9C8E79 | secondary text |
| pacific | #2F8578 | links, water moments |
| signal | #C6D230 | LIVE DATA ONLY (charts, status, metrics) |
| clay | #DE8248 | primary accent: CTAs, mark node, section indices |

Ratio: ~60% ink/graphite, ~30% bone, ~10% color. Never combine signal + clay in one component.

## Typography
- **Archivo** (variable, use the wdth axis): display 800 / width 118 / -2.5% tracking; headings 700 / width 112; body 400 / 1.65 leading.
- **IBM Plex Mono** 400–600: labels, coordinates, metrics, version tags — always uppercase, +14% tracking, one line max.
- next/font: `Archivo({ subsets:['latin'], axes:['wdth'] })`, `IBM_Plex_Mono({ subsets:['latin'], weight:['400','500','600'] })`.

## Marks
- **Primary:** SP route monogram (assets/sp-monogram-*.svg, components/SpMonogram.jsx). Continuous route strokes; single clay node terminates the S. Clearspace = 1 stroke width; min 20px wide; never recolor strokes or add gradients.
- **Secondary:** swell mark (assets/swell-mark-*.svg, components/SwellMark.jsx). Favicon/app icon/avatar/bullets. At 16px use two lines, no node (assets/favicon.svg).

## Hero recipe (assets/hero-background.svg)
Graphite base → faint dot grid (radial-gradient, 26px) → horizon rule at 58% → contour swells below →
one clay route climbing left-to-right ending in a bone node → warm clay glow low near the horizon.
Text occupies the left 55%. Animate the route with stroke-dashoffset on load (600ms ease-out) — the one flourish.

## Motifs
1. Survey grid: 22–26px dot grid at ~12% tone (CSS radial-gradient).
2. Contour lines: quiet topo/swell curves for hero + footer texture.
3. Route + waypoints: card headers, dividers, progress.
4. Coordinate rules: vertical hairlines + geo tags (33.66°N 117.91°W) in footers.

## Modes
Dark is default. Light mode swaps ink<->bone, links pacific, accents clay. Signal stays data-only in both.

## Asset checklist for the site
- favicon.svg (+ 32/16px PNG renders), apple-touch-icon 180px on graphite
- OG image 1200x630: graphite base, clay route lower-right, empty left for type
- Avatars: monogram centered in a circle — graphite bg (dark) or bone bg (light)
