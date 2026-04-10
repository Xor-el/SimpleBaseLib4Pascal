# SimpleBaseLib4Pascal — lightweight brand guide

## Primary mark

- **Default:** `logo.svg` — **encode pipeline**: three horizontal **byte bars**, a **chevron** (transform), four **symbol columns** (alphabet output). Evokes grouping bytes into encoded text (e.g. 3→4 style) without tying the brand to a single base.
- **Dark UI:** `logo-dark.svg` — same layout with higher-contrast mint / teal / lilac on a deeper indigo badge.

## Palette (default logo)

| Role | Hex | Notes |
|------|-----|--------|
| Badge top | `#4338ca` | Indigo gradient start. |
| Badge bottom | `#1e1b4b` | Deep indigo end. |
| Byte bars | `#99f6e4` | Input / raw chunks. |
| Chevron | `#5eead4` | Transform / direction. |
| Symbol columns | `#f0abfc` | Encoded alphabet slots. |

Dark variant uses `#1e1b4b`–`#0c0a18`, byte bars `#ccfbf1`, chevron `#2dd4bf`, columns `#f5d0fe`.

**Banner background** (social / OG composites from `tools/branding/export.mjs`): RGB **48, 41, 138** (`#30298a`), midpoint of the default badge gradient.

## Typography (pairing)

The logo has **no embedded wordmark**. When setting type next to the mark:

- Prefer **clean sans-serif** UI fonts (e.g. Segoe UI, Inter, Source Sans 3).
- **Do not** use Embarcadero product logotypes alongside this mark in a way that suggests an official bundle.

## Clear space

Keep padding around the badge at least **1/4 of the mark width** on a square canvas. Do not crop flush against the rounded corners.

## Minimum size

- **Favicon / IDE:** target **16×16** in ICO; **32×32** or larger is clearer.
- **README / docs:** **128–200 px** wide for the SVG is typical.

## Correct use

- Scale **uniformly**.
- Use `logo-dark.svg` on **dark** pages for contrast.
- Prefer **SVG** on the web; **PNG** where required.

## Incorrect use

- Do not **stretch**, **skew**, or **recolor** arbitrarily outside this palette without updating `BRAND.md`.
- Do not **drop** the badge frame or use only the chevron / bars in isolation at small sizes (loses identity).
- Do not place **third-party logos inside** the badge.

## Wordmark

“SimpleBaseLib4Pascal” in plain text beside or below the mark is enough; no custom logotype is required.
