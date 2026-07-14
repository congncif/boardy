# Boardy ownership and release authority

Updated: 2026-07-14

## Current authority

The requester authorized implementation on `codex/boardy-1.61.0` and `codex/uicomposable-1.1.0`, semantic commits, pushes, annotated Git tags and GitHub Releases after technical gates pass. CocoaPods trunk publication is explicitly excluded from this execution.

GitHub evidence confirms authenticated account `@congncif` has administrator and push permission on both repositories. That establishes a release actor; it does not by itself designate all governance roles.

| Role | Designation | Status |
|---|---|---|
| Technical owner | Not yet explicitly designated | Blocking final GitHub Release |
| Backup owner | Not yet explicitly designated | Blocking final GitHub Release |
| Release actor | `@congncif` | Confirmed by repository permission |
| Security contact/private channel | Not yet explicitly designated | Blocking final GitHub Release |
| Boardy write collaborator candidate | `@congnc1` | Has write access; not assumed to be backup |

## Publication rule

Implementation, commits and branch pushes may continue. Final Git tags and GitHub Releases remain disabled until the technical owner, backup owner and private security contact are explicitly recorded here and represented in `CODEOWNERS`/`SECURITY.md` where applicable.

No command in this release may register a CocoaPods trunk session or publish Boardy/UIComposable pods. Podspec validation and version metadata are preparation only.

## Responsibility model

- The technical owner approves public behavior, support matrix, deprecation and release readiness.
- The backup owner must have enough repository access and release knowledge to continue maintenance.
- The release actor executes the documented checklist against the reviewed commit and verifies peeled local/remote tags.
- The security contact receives private vulnerability reports and coordinates disclosure.
- Work-item completion requires executable evidence; repository permission alone is not approval evidence.
