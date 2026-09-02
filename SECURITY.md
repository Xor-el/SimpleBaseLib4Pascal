# Security policy

SimpleBaseLib4Pascal is a base encoding/decoding library (Base2 through Base85 and friends). It does
not provide cryptographic confidentiality or authenticity — but memory-safety and correctness bugs in
its encode/decode paths can still be serious (crashes, corrupted data, or exploitable overreads),
especially where an application feeds it attacker-controlled input. We take reports of these
seriously and are grateful to anyone who reports them responsibly.

## Supported versions

`master` is the actively maintained branch and the source for all releases. Fixes land on `master`
first and ship in the next tagged release, so `master` may already contain a fix that hasn't been
released yet — please check against `master` before reporting an issue. Older tagged releases are not
backported to.

## Reporting a vulnerability

**Please report security issues privately — do not open a public issue, pull request, or discussion
for a suspected vulnerability.**

Preferred channel: **GitHub private vulnerability reporting.** On this repository, go to the
**Security** tab → **Report a vulnerability**.

A good report includes:

- the affected base/codec and variant (e.g. `TBase58.Bitcoin`, `TBase64.Url`, the stream-based API)
  and version or commit;
- a clear description of the issue and its impact (crash, out-of-bounds read/write, incorrect
  encode/decode result, unbounded memory/CPU use, etc.);
- a minimal reproduction — the input bytes/string that trigger it — and the affected toolchain
  (Delphi or FreePascal, version, OS, architecture) where relevant;
- any suggested remediation, if you have one.

You do not need a working exploit — a credible analysis of a broken invariant (e.g. a bounds check
that can be bypassed) is enough.

## What to expect

This is a solo-maintained open-source project, so responses are best-effort rather than covered by a
formal SLA. In general you can expect:

- **Acknowledgement** of your report, typically within a few days.
- An initial **assessment** (is it a vulnerability, likely severity, affected versions) once it's
  been reviewed.
- **Coordinated disclosure.** We aim to develop and release a fix before public disclosure, and to
  coordinate timing with you. Our default embargo target is **90 days** from the initial report,
  shorter for issues under active exploitation and extendable by mutual agreement for complex fixes.
- **Credit** in the release notes, if you'd like it. Let us know if you'd prefer to remain anonymous.

## Scope

**In scope** — issues in the encode/decode implementations this repository ships:

- memory-safety bugs in the `TryEncode`/`TryDecode` and allocating encode/decode APIs (out-of-bounds
  read/write, incorrect buffer-size calculations);
- incorrect round-tripping (encode then decode does not reproduce the original bytes) for any
  supported base/alphabet;
- a decoder that accepts malformed or non-canonical input as valid when it should reject it (or vice
  versa), where that has a security-relevant consequence for a typical caller;
- unbounded memory or CPU consumption when encoding/decoding attacker-controlled input, including via
  the stream-based APIs;
- integer overflow in size/length calculations on large inputs.

**Out of scope / report elsewhere:**

- Lack of confidentiality, integrity-against-tampering, or authentication — this library encodes and
  decodes data, it does not encrypt, sign, or verify it. If you need those properties, they belong in
  a cryptographic layer above this library, not here.
- General bugs, incorrect documentation, or feature requests with no security impact — please use the
  normal [issue tracker](https://github.com/Xor-el/SimpleBaseLib4Pascal/issues) for those.
- Issues in third-party code that merely uses this library.
