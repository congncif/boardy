## Summary

<!-- What changes, and what concrete problem does it solve? -->

## Scope and design

<!-- Why does this belong in Boardy rather than an application, board/plugin, or extension package? -->

- Change type: <!-- bug fix / internal hardening / additive API / deprecation / documentation -->
- Related issue:
- ADR or RFC: <!-- Link the accepted decision, or explain why none is required. Public API additions require an accepted RFC. -->

## Test evidence

<!-- List exact commands, destination/toolchain, and observed results. Link or attach relevant test output when available. -->

- Tests added or updated:
- Commands and results:
- Areas not tested and why:

## Compatibility and migration impact

<!-- Cover public API/interface changes, observable behavior, callback executor/order, iOS 14+, Swift 5/6 modes, and SwiftPM/CocoaPods consumers. -->

- Public API/interface impact:
- Behavioral or concurrency impact:
- Minimum-platform impact:
- Consumer migration required:
- Documentation or migration guide updated:

## Checklist

- [ ] I kept the change to the approved scope and linked its issue or decision.
- [ ] I added or updated regression tests for executable behavior, or explained why tests are not applicable.
- [ ] I recorded the local verification commands and their actual results above.
- [ ] I considered SwiftPM and CocoaPods integration impact.
- [ ] I documented public API, behavior, concurrency, and migration consequences.
- [ ] I added an ADR/RFC for a new public contract, or explained why none is required.
- [ ] I did not include generated dependency sources or unrelated changes.
- [ ] I followed the [Code of Conduct](https://github.com/congncif/boardy/blob/master/CODE_OF_CONDUCT.md) and contribution guidelines.

> [!IMPORTANT]
> Do not disclose vulnerability details in a public pull request. Coordinate a
> security fix through the private channel in the project's
> [Security Policy](https://github.com/congncif/boardy/security/policy).
