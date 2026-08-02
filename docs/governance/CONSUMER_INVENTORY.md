# Boardy 1.x consumer inventory

Captured: 2026-07-14 from local sibling repositories under `/Volumes/KingstonXS1000/WORKSPACE/ABC`.

Application owners were not supplied. The Boardy owner approved the release-level disposition on
2026-07-14: the GitHub-only 1.61.0 release is opt-in, CocoaPods is not published, and every existing
consumer stays on its current Boardy line until its own owner schedules an iOS 14 migration. Before
any later CocoaPods publication, every unbounded dependency below iOS 14 must add a `< 1.61` ceiling,
raise its floor, or be retired. This inventory therefore closes the release blast-radius decision
without claiming that application migrations are complete.

| Application/module | Owner | Boardy version | Integration method | Swift/Xcode | Migration risk | Validation status |
|---|---|---|---|---|---|---|
| Shophouse app and modules | Not confirmed | 1.60.1 lock; unbounded `pod "Boardy"` | CocoaPods | App/pods target iOS 13 | **High:** raise app and affected module floors to iOS 14 or constrain Boardy `< 1.61`; 498 Swift imports | Manifest/source inventory complete; migration not executed |
| Shophouse DadAds and DADUpload examples | Not confirmed | 1.15.3 lock | CocoaPods | iOS 11 | **High:** remain on legacy Boardy unless examples raise to iOS 14 | Lock/platform confirmed |
| QuizCombatApp | Not confirmed | 1.60.1 lock; unbounded dependency | CocoaPods | App iOS 16.6 | **Medium:** app can adopt, but four iOS 13 podspecs must raise floor or pin `< 1.61`; 340 Swift imports | Manifest/source inventory complete; migration not executed |
| QuizCombat, QuizCombatPlugins, QuizEngine, QuizEnginePlugins | Not confirmed | Inherit unbounded Boardy dependency | CocoaPods podspecs | iOS 13 | **High:** incompatible with Boardy 1.61 platform floor | Four podspec minima confirmed |
| SiFUtilities `Boardy` subspec | Not confirmed | Unbounded `Boardy/ComponentKit`; example lock 1.36.1 | CocoaPods | Root iOS 10; example iOS 11 | **High:** give subspec an iOS 14 floor or constrain Boardy `< 1.61` | Podspec/source/lock confirmed |
| `module-structure-template` | Not confirmed | Unbounded Boardy dependency | CocoaPods template | Generated podspecs iOS 11 | **High:** template must stop generating incompatible unbounded metadata before later pod publication | Two podspec templates confirmed |
| `module-template` | Not confirmed | Generated imports | Source template | Platform varies | **Medium:** generated modules need an iOS 14 compatibility rule | 73 template Swift imports found |
| Boardy Example | Boardy maintainers | 1.60.1 current lock; 1.60.0 at initial audit | Local CocoaPods development pod | Repository example | Internal migration is part of 1.61 work | Current lock rechecked 2026-07-14 |

## Executor compatibility evidence

- Shophouse contains 20 `BlockTaskBoard` factories; 11 use `.concurrent`.
- QuizCombatApp contains 16 `BlockTaskBoard` factories; all 16 use `.concurrent`.
- Multiple consumers explicitly dispatch task completion work to the main queue.
- `PhotoUploadServiceBoard` combines `.concurrent`, `DispatchQueue.global` execution and an explicit main-queue completion hop.

This evidence supports preserving the legacy executor and complete terminal ordering for
`BlockTaskBoard` in the minor release. It does not establish a safe actor-isolation model for the
rest of Boardy; that design is deferred to a separate plan.

## Release disposition

This execution creates Git tags/GitHub Releases only and does not publish CocoaPods, so existing pod consumers will not resolve 1.61.0 automatically. Before a later CocoaPods publication, each unbounded dependency below iOS 14 must either migrate its platform floor, add an explicit `< 1.61` version ceiling, or record retirement. The Boardy owner owns this publication gate; application owners own their eventual migrations.
