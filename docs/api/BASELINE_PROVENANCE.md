# Boardy public API baseline provenance

This directory holds the immutable textual baselines used to verify source compatibility. It holds
**no digester graphs** — those are derived on demand, see below.

| Artifact | Role | SHA-256 |
|---|---|---|
| `Boardy-1.62.0.swiftinterface` | **Active baseline.** Every candidate is verified against it. | `37c9a630b003e60c3e854726fb87d92022670b1e8a1cb2d41cb7d398b8c4ac91` |
| `Boardy-1.61.0.swiftinterface` | Previous released line; retained as the release record. | `21ff72a7fd1c4eb0062aac23c0d4d9748c37a9b39fe1e5abbd64e4dc6d9ee85a` |
| `Boardy-1.60.1.swiftinterface` | Retained for provenance and for re-running the 1.60.1 → 1.61.0 comparison. | `a29d4bb97a6214d477c3fa739366616d911393a2d557c5d4d62c69c834454bb9` |

## Why 1.63.0 has no file here

1.63.0 fixes defects and changes observable behavior but touches no declaration, so its captured
interface is byte-identical to 1.62.0's. The active baseline therefore stays at 1.62.0 rather than
gaining a third identical copy. Verification is unaffected: comparing 1.63.0 against 1.62.0 is
comparing it against its own surface, which is exactly what "no API change" means.

## 1.62.0 capture

Taken from the `api-verify` artifact of the CI run on the tagged commit
`46f8d22` — the same interface the release was verified against, not a local
rebuild. Byte-identical to an independent local build on a different machine,
which is the reproducibility claim the derived-graph approach rests on.

## 1.60.1 capture

| Field | Value |
|---|---|
| Source commit | `bfa9579977047b6e112b40b94c4c49243eb46dc8` |
| Source commit timestamp | `2026-07-14 10:37:44 +0700` |
| Capture toolchain | Xcode `26.4.1` (`17E202`) |

Captured from the source tree at that commit before any 1.61.0 source mutation, and committed
separately from those changes so the reference stays independently auditable.

## Why no graphs are committed

The directory previously carried three digester graphs totalling 4.4 MB. All three are reproducible
from the interfaces above with `tools/derive-api-graph.sh`, and reproducing them was verified to
give the same verification verdict, the same report body, and the same detection of an injected
removal. Their contract is semantic, not byte-level: the output is not reproducible byte-for-byte
across toolchains, so committing one would assert a stability it does not have.

One of the three was worse than redundant. The raw `Boardy-1.60.1.api.json` was labelled
authoritative but was never what the verification actually read: comparing against it reported two
inherited constructors as removed and fourteen phantom type changes, none of them real. The
`Boardy-1.60.1.interface.api.json` beside it existed only to route around that file.

## The two graph forms are not interchangeable

This is the trap that produced the phantom findings above, and it is a property of the tooling
rather than of any one file:

| Form | Produced by | `FlowMotherboard` prints as |
|---|---|---|
| interface-derived | `tools/derive-api-graph.sh` | `FlowManageable & MotherboardType` (typealias expanded) |
| binary-module-derived | `tools/capture-public-api.sh` | `FlowMotherboard` (sugar preserved) |

Comparing one against the other reports every sugared declaration as a type change — 40+ findings on
Boardy, none real. Both sides of a comparison must therefore be interface-derived.
`capture-public-api.sh` still writes a graph, and CI discards it; only the `.swiftinterface` that
step captures is used.

## Reproducing a graph

The interfaces open with `@_exported import Boardy`, so they do not load standalone through `-I`
(`error: underlying Objective-C module 'Boardy' not found`). `derive-api-graph.sh` handles this by
copying a freshly built `Boardy.framework`, deleting every shipped module slice and substituting the
interface being examined.

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild build -workspace Example/Boardy.xcworkspace -scheme Boardy \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build-local/DerivedData-api \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES CODE_SIGNING_ALLOWED=NO

tools/derive-api-graph.sh docs/api/Boardy-1.62.0.swiftinterface \
  .build-local/DerivedData-api .build-local/api/baseline.api.json
```

`BUILD_LIBRARY_FOR_DISTRIBUTION=YES` is not optional: without library evolution no
`.swiftinterface` is emitted and there is nothing to capture or compare.

The `api-verify` job in `.github/workflows/ci.yml` runs the whole chain on every push and uploads
the report, the rendered inventory and the candidate interface.
