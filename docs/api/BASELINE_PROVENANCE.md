# Boardy 1.60.1 API baseline provenance

This directory contains the immutable public API baseline used to review the
source compatibility of Boardy `1.61.0`.

| Field | Value |
|---|---|
| Source commit | `bfa9579977047b6e112b40b94c4c49243eb46dc8` |
| Source commit subject | `docs: add Boardy living roadmap` |
| Source commit timestamp | `2026-07-14 10:37:44 +0700` |
| Capture toolchain | Xcode `26.4.1` (`17E202`) |
| Swift interface SHA-256 | `a29d4bb97a6214d477c3fa739366616d911393a2d557c5d4d62c69c834454bb9` |
| API digester JSON SHA-256 | `1a3b741beeef2bfaccac0b79ee07baa65f3da2343c03ce277df111f95b4199df` |

The artifacts were captured and validated from the source tree at the commit
above before any Task 2–8 Boardy source mutation. They are committed separately
from those source changes so the compatibility reference remains independently
auditable.

The raw API graph is retained unchanged for provenance. During the 1.61.0 review,
the raw graph was found to contain declarations and type spellings that are not
present in its paired textual interface (including synthesized `Equatable`
members). `Boardy-1.60.1.interface.api.json` is therefore an additional,
deterministic comparison graph dumped from that immutable interface with the same
Xcode toolchain and interface-loading mode used for the candidate. It does not
replace the raw capture; it prevents a tooling-format mismatch from being
reported as a source compatibility break.

Artifacts:

- `Boardy-1.60.1.swiftinterface`: public, host-compatible simulator interface.
- `Boardy-1.60.1.api.json`: authoritative Swift API Digester graph.
- `Boardy-1.60.1.interface.api.json`: normalized interface-derived comparison graph;
  SHA-256 `4a756df2debb2be8e071ed389914121c97474687d7aa1436b6d3e7967b26a1f1`; the raw graph above
  remains immutable and authoritative for capture provenance.

Extraction and comparison use `tools/capture-public-api.sh` and
`tools/verify-public-api.sh`. Project-scoped temporary files and build products
are written below the ignored repository-local `.build-local/` directory.
