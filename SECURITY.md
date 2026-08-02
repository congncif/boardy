# Security Policy

## Supported versions

Boardy does not yet have an owner-approved long-term security-maintenance
window. Reports and fixes follow this best-effort boundary:

| Version | Security status |
| --- | --- |
| `1.63.x` | Current line; fixes land here |
| `1.62.x` | Superseded; report against it, but expect the fix on 1.63.x |
| `1.61.x` | Superseded |
| `1.60.1` | Last line published to the CocoaPods trunk; best effort only |
| `1.60.0` and earlier | Unsupported |

Unsupported versions may still be affected by a report, but fixes are not
backported unless a published advisory explicitly says otherwise. This policy
does not promise a response or remediation SLA.

## Report a vulnerability privately

**Never disclose a suspected vulnerability in a public issue, pull request,
discussion, commit, or other public channel.**

Send a private email to [congnc.if@gmail.com](mailto:congnc.if@gmail.com) with
the subject `[Boardy Security]`:

1. Include the affected Boardy version or commit, impact, reproduction steps or
   proof of concept, affected environment, and any known mitigations.
2. State any disclosure timeline or credit preference.
3. Do not copy a public mailing list or paste the report into a public GitHub
   artifact.

The repository's GitHub Private Vulnerability Reporting feature is currently
disabled. Consequently, the **Report a vulnerability** form is not an active
channel and the private email above is the confirmed reporting path. Before the
project advertises GitHub reporting, a repository owner must enable and verify
the feature and configure its notifications; public issues are never an
acceptable fallback.

## What to expect

Security reports and proposed fixes should remain private until a coordinated
disclosure is agreed. The security contact will triage the report, request
additional information when necessary, coordinate a fix and advisory, and
credit reporters who request credit. Response-time and remediation targets
remain undefined until the designated owners accept them.

Boardy has one maintainer, who is also the security contact and the release
actor; no backup contact is designated. This is a known operational risk and it
is why no response SLA is offered. A report that receives no acknowledgement
should be resent rather than assumed lost.

Please report vulnerabilities in Boardy itself or in artifacts published by the
Boardy project. For a vulnerability that originates entirely in a third-party
dependency, also follow that dependency's security policy; include its advisory
reference in the private Boardy report when Boardy consumers may be affected.
