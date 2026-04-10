# Package icons

| File | Contents |
|------|-----------|
| `SimpleBaseLib4Pascal.ico` | Multi-size Windows icon (16, 32, 48, 256), generated from `../logo.svg`. |

## Using in Delphi (`.dproj`)

1. **Project → Options → Application** (or **Icons** depending on version).
2. Set **Application icon** to `assets\branding\icons\SimpleBaseLib4Pascal.ico` (path relative to the `.dproj` as your IDE expects).

## Using in Lazarus (`.lpi`)

1. **Project → Project Options → Application** — set **Icon** to this `.ico`.

## Regeneration

After changing `../logo.svg`, rebuild the ICO using [tools/branding/README.md](../../../tools/branding/README.md).
