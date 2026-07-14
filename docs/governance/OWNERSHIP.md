# Boardy ownership and release authority

Updated: 2026-07-14

## Current authority

The requester authorized implementation on `codex/boardy-1.61.0` and `codex/uicomposable-1.1.0`, semantic commits, pushes, annotated Git tags and GitHub Releases after technical gates pass. CocoaPods trunk publication is explicitly excluded from this execution.

GitHub evidence confirms authenticated account `@congncif` has administrator and push permission on both repositories. The requester designated that account as the sole owner and release authority for this release. A backup account may be added later, but it is not a 1.61.0 release gate.

| Role | Designation | Status |
|---|---|---|
| Technical owner | `congnc.if@gmail.com` / `@congncif` | Confirmed by requester on 2026-07-14; handle matched to its public GitHub profile |
| Backup owner | Not designated | Explicitly deferred by requester on 2026-07-14; does not block 1.61.0 |
| Release actor | `@congncif` | Confirmed by repository permission |
| Security contact/private channel | `congnc.if@gmail.com` | Confirmed by requester on 2026-07-14 |

## Publication rule

Implementation, commits, branch pushes, final Git tags and GitHub Releases are authorized for `@congncif` after the documented local technical gates pass. Ownership and security designations must be represented in `CODEOWNERS` and `SECURITY.md`. Consumer applications do not receive 1.61.0 automatically because CocoaPods publication is excluded; their migration remains separately owned adoption work.

No command in this release may register a CocoaPods trunk session or publish Boardy/UIComposable pods. Podspec validation and version metadata are preparation only.

## Responsibility model

- The technical owner approves public behavior, support matrix, deprecation and release readiness.
- The release actor executes the documented checklist against the reviewed commit and verifies peeled local/remote tags.
- The security contact receives private vulnerability reports and coordinates disclosure.
- Work-item completion requires executable evidence; repository permission alone is not approval evidence.

## Deferred continuity work

The single-owner model is an accepted operational risk for 1.61.0. Adding a backup maintainer,
documenting handover and testing independent release access remain follow-up governance work rather
than publication prerequisites for this release.
