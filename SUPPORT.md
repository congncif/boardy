# Boardy support

## Version status

Boardy does not yet have an owner-approved long-term support or response-time policy. Until that
policy exists, maintenance and triage are best effort and no service-level agreement is guaranteed.

| Version | Status | Platform and evidence boundary |
|---|---|---|
| 1.61.0 | Unreleased candidate under implementation; not production/G1 supported | Selected floor is iOS 14+; current verification is limited to Xcode 26.4.1 on iPhone 17 / iOS 26.4. Hosted CI, older runtimes/devices and N-1 Xcode are deferred. |
| 1.60.1 | Current released legacy line | CocoaPods release with an iOS 12 floor; fixes and response times are not guaranteed. |
| 1.60.0 and earlier | Historical | No active maintenance commitment. Use tags and commit history as the record. |

The current evidence boundary is in the
[`living roadmap`](docs/BOARDY_LIVING_ROADMAP.md); the
release task must add `docs/COMPATIBILITY.md` before publication. A consumer below iOS 14 must
remain below Boardy 1.61 unless it raises its deployment target.

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
project's support scope. The consumer inventory in
[`docs/governance/CONSUMER_INVENTORY.md`](docs/governance/CONSUMER_INVENTORY.md) records known
compatibility risks but does not assign support ownership.
