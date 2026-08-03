# Boardy support

## Version status

Boardy does not yet have an owner-approved long-term support or response-time policy. Until that
policy exists, maintenance and triage are best effort and no service-level agreement is guaranteed.

| Version | Status | Platform and evidence boundary |
|---|---|---|
| 1.63.1 | Current line; Git tag only | iOS 14+. Documentation and test-suite release: no shipped code changed, so a consumer on 1.63.0 is running identical library code. |
| 1.63.0 | On the CocoaPods trunk | iOS 14+. Every push runs hosted CI on Xcode 26.4.1 / `macos-26`: build, tests, podspec lint and public-API verification. Older runtimes, other devices and N-1 Xcode remain unverified. |
| 1.62.0 | Released, superseded by 1.63.0 | iOS 14+. Git tag only — never published to the CocoaPods trunk. |
| 1.61.0 | Released | iOS 14+. Published as a Git tag and to the CocoaPods trunk. |
| 1.60.1 | Last line with an iOS 12 floor | On the CocoaPods trunk; pin `~> 1.60` to stay here. Fixes and response times are not guaranteed. |
| 1.60.0 and earlier | Historical | No active maintenance commitment. Use tags and commit history as the record. |

The current evidence boundary is in [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md).

The CocoaPods trunk serves up to 1.63.0, so a dependency without a version bound resolves it and
inherits the iOS 14 floor. 1.63.1 is not on the trunk and does not need to be: it changes no shipped
code. An application that must stay below iOS 14 pins `~> 1.60`. 1.62.0 was
skipped on the trunk, so a pod consumer moving from 1.61.0 lands on 1.63.0 and takes both changelogs
at once.

## Where to ask

Choose the channel by the type of request:

- **Reproducible bug:** use the repository's bug-report form in
  [GitHub Issues](https://github.com/congncif/boardy/issues/new/choose). Include the Boardy version,
  integration method, Xcode/Swift/iOS versions, minimal reproduction and relevant logs.
- **Feature or architecture proposal:** use the feature-request form. Explain why the capability
  belongs in Boardy 1.x rather than in an application or plugin, and identify any API or migration
  impact.
- **Usage question:** an official question/support channel has not yet been approved. If the
  repository enables GitHub Discussions, use its Q&A category; otherwise do not file a question as
  a bug merely to obtain a response.
- **Security vulnerability:** do not create a public issue, discussion or pull request. Follow
  [`SECURITY.md`](SECURITY.md) and use the private reporting mechanism documented there.

The public tracker is not suitable for private application code, credentials, customer data or
proprietary logs. Reduce reproductions to the minimum needed and remove sensitive material.

## Response expectations

Maintainers may acknowledge, request a reproduction, label, close or defer an item according to
impact and available capacity. No acknowledgement, triage, fix or release deadline is guaranteed
until the technical owner adopts an explicit SLA.

Opening an issue does not make a proposed behavior part of the supported public contract. Accepted
behavior is defined by released code, API stability documentation, migration notes and accepted ADRs.

## Scope of help

Useful reports isolate behavior in Boardy itself. App-specific architecture design, migration of an
entire proprietary codebase and debugging third-party dependencies may require work outside this
project's support scope. [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md) records the known
compatibility boundary but does not assign support ownership for consumer applications.
