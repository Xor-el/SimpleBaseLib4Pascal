# SimpleBaseLib4Pascal

[![Build Status](https://github.com/Xor-el/SimpleBaseLib4Pascal/actions/workflows/make.yml/badge.svg)](https://github.com/Xor-el/SimpleBaseLib4Pascal/actions/workflows/make.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Xor-el/SimpleBaseLib4Pascal/blob/master/LICENSE)
[![Delphi](https://img.shields.io/badge/Delphi-2010%2B-red.svg)](https://www.embarcadero.com/products/delphi)
[![FreePascal](https://img.shields.io/badge/FreePascal-3.2.2%2B-blue.svg)](https://www.freepascal.org/)

SimpleBaseLib4Pascal is a base encoding/decoding library for Object Pascal with support for multiple base families, non-allocating APIs, and stream-based APIs across Delphi and FreePascal.

## Table of Contents

- [Features](#features)
- [Available Encodings](#available-encodings)
- [Getting Started](#getting-started)
- [Quick Examples](#quick-examples)
- [Running Tests](#running-tests)
- [Tip Jar](#tip-jar)
- [License](#license)

## Features

- Base encoding/decoding implementations for common and extended base families.
- Multiple alphabet variants for several bases (for example Base32, Base58, Base64, Base85).
- Non-allocating `TryEncode`/`TryDecode` APIs for performance-sensitive paths.
- Stream-based encode/decode support for large inputs.
- Compatible with both Delphi and FreePascal toolchains.

## Available Encodings

- **Base2**
- **Base8**
- **Base10**
- **Base16**
- **Base32** (RFC 4648, Crockford, Extended Hex, and more)
- **Base36**
- **Base45**
- **Base58** (Bitcoin, Ripple, Flickr, Monero variants)
- **Base62**
- **Base64** (Default, URL-style variants)
- **Base85** (Ascii85, Z85)

## Getting Started

### Prerequisites

- **Delphi:** 2010 and above
- **FreePascal:** 3.2.2 and above

### Installation

#### Delphi

1. Open package:
   - `SimpleBaseLib/src/Packages/Delphi/SimpleBaseLib4PascalPackage.dpk`
2. Build and install the package in the IDE.
3. Add `SimpleBaseLib/src` subfolders to your project search path if needed.

#### FreePascal / Lazarus

1. Open package:
   - `SimpleBaseLib/src/Packages/FPC/SimpleBaseLib4PascalPackage.lpk`
2. Build/install package in Lazarus, or add `SimpleBaseLib/src` paths to your FPC project.

## Quick Examples

### Base16 Encode/Decode

```pascal
uses
  SysUtils, SbpBase16;

var
  LBytes: TBytes;
  LText: String;
begin
  LBytes := TBytes.Create($DE, $AD, $BE, $EF);
  LText := TBase16.UpperCase.Encode(LBytes); // DEADBEEF
  LBytes := TBase16.UpperCase.Decode(LText);
end;
```

### Base64 URL Variant

```pascal
uses
  SysUtils, SbpBase64;

var
  LData: TBytes;
  LEncoded: String;
begin
  LData := TBytes.Create($FB, $FF, $EF);
  LEncoded := TBase64.Url.Encode(LData);
  LData := TBase64.Url.Decode(LEncoded);
end;
```

## Running Tests

Tests are provided for both Delphi and FreePascal.

- **Delphi:** open and run
  - `SimpleBaseLib.Tests/Delphi.Tests/SimpleBaseLib.Tests.dpr`
- **FreePascal/Lazarus:** open and run
  - `SimpleBaseLib.Tests/FreePascal.Tests/SimpleBaseLib.Tests.lpi`

## Tip Jar

If you find this library useful and would like to support its continued development, tips are greatly appreciated! 🙏

| Cryptocurrency | Wallet Address |
|---|---|
| <img src="https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/icon/btc.png" width="20" alt="Bitcoin" /> **Bitcoin (BTC)** | `bc1quqhe342vw4ml909g334w9ygade64szqupqulmu` |
| <img src="https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/icon/eth.png" width="20" alt="Ethereum" /> **Ethereum (ETH)** | `0x53651185b7467c27facab542da5868bfebe2bb69` |
| <img src="https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/icon/sol.png" width="20" alt="Solana" /> **Solana (SOL)** | `BPZHjY1eYCdQjLecumvrTJRi5TXj3Yz1vAWcmyEB9Miu` |

## License

This project is licensed under the [MIT License](LICENSE).
