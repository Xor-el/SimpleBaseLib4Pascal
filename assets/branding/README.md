# SimpleBaseLib4Pascal branding

This folder holds the **project logo** and derivative assets for README, social previews, and optional IDE package icons.

## Meaning

The mark is a **rounded badge** showing an **encode pipeline**: three **byte bars** on the left, a **chevron** in the middle, and four **symbol columns** on the right. It suggests:

- **Bytes → alphabet output** — the core idea of base encoding (many bases, one flow).
- **Clarity** — simple geometry that stays readable at favicon size.

It is **not** derived from Embarcadero, Delphi, or other third-party artwork. Do not combine it with third-party trademarks in a way that implies endorsement.

## Files

| File | Use |
|------|-----|
| `logo.svg` | **Source of truth** (default README / light UI). |
| `logo-dark.svg` | Dark backgrounds (docs sites, dark-themed pages). |
| `BRAND.md` | Colors, clear space, minimum size, do / don't. |
| `export/*.png` | Raster exports (GitHub social 2:1, Open Graph, social header, square avatar). |
| `icons/SimpleBaseLib4Pascal.ico` | Multi-resolution Windows icon for `.dproj` / `.lpi`. |

## License

The **library source code** is under the project [MIT License](../../LICENSE). The **logo files in this directory** are also released under the **MIT License** unless the repository maintainers specify otherwise in a future commit; you may use them to refer to SimpleBaseLib4Pascal. Do not use them to misrepresent authorship or to imply certification by the authors.

## Regenerating PNG and ICO

If you change the SVG, regenerate rasters using one of:

- **Inkscape** (CLI): export PNG at the sizes listed in `export/README.md`.
- **ImageMagick** 7+: `magick logo.svg -resize 512x512 export/logo-512.png` (and similar).

For a scripted pipeline, see [tools/branding/README.md](../../tools/branding/README.md).

Exact filenames and pixel sizes are listed in `export/README.md`.
