# Boardy — Living Assessment, Evolution & Open-Source Roadmap

> Tài liệu tổng hợp để review, lựa chọn và theo dõi từng bước nâng cấp Boardy.
>
> **Trạng thái quyết định:** Option A đang được thực thi trên branch `codex/boardy-1.61.0`; Boardy floor là iOS 14+; requester yêu cầu dùng Xcode 26.4.1 hiện có và chỉ phát hành qua Git/GitHub, chưa publish CocoaPods. GitHub-only 1.61.0 có thể release sau local gates nhưng không đạt G1; hosted CI, N-1 Xcode và toàn bộ MainActor/Swift 6 isolation được tách sang các plan sau.

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái tài liệu | In progress — Option A execution |
| Phiên bản tài liệu | 0.17.0 |
| Ngày audit | 2026-07-14 |
| Cập nhật gần nhất | 2026-07-14 |
| Audit baseline | `d62970a81432` |
| Option A source/API baseline | `bfa9579977047b6e112b40b94c4c49243eb46dc8` |
| Immutable API-baseline commit | `53664db10ae92924a6a7ca97bf0d0b906d0a3cca` |
| Tasks 2–8 checkpoint | `f4284278c348f279c833c32e231d39473e5dd5f1` |
| Framework release hiện tại | `1.60.1` |
| Owner tài liệu | Technical owner `congnc.if@gmail.com` (`@congncif`) |
| Phạm vi | Vision, architecture, source, tests, documentation, distribution, OSS governance và organizational adoption |
| Ngoài phạm vi audit | Production telemetry, consumer interviews, legal review chính thức và performance profiling trên ứng dụng thật |

---

## 0. Cách sử dụng living document

Tài liệu này có bốn mục đích:

1. Lưu lại baseline và bằng chứng để không phải audit lại từ đầu.
2. Tách rõ phát hiện, đề xuất và quyết định đã được phê duyệt.
3. Cho phép chọn từng work item theo giá trị, chi phí và dependency.
4. Theo dõi tiến độ đến khi Boardy đủ điều kiện trở thành framework được khuyến nghị trong tổ chức và phát hành open source ổn định.

### 0.1. Trạng thái work item

| Trạng thái | Ý nghĩa |
|---|---|
| `Proposed` | Mới là đề xuất trong audit, chưa được phê duyệt |
| `Selected` | Đã được chọn vào phạm vi thực hiện |
| `In progress` | Đang thực hiện |
| `Blocked` | Đã được chọn nhưng đang có blocker được ghi rõ |
| `Done` | Hoàn tất và có evidence đáp ứng acceptance criteria |
| `Deferred` | Hợp lý nhưng chủ động để lại cho giai đoạn sau |
| `Rejected` | Đã xem xét và quyết định không thực hiện; lý do phải được lưu trong Decision Log |

### 0.2. Mức ưu tiên

| Mức | Định nghĩa |
|---|---|
| `P0` | Blocker về correctness, build trust, security, distribution hoặc khả năng chuyển sang Swift 6 |
| `P1` | Rủi ro cao đối với maintainability, lifecycle, adoption hoặc API stability |
| `P2` | Cải thiện quan trọng nhưng chưa chặn việc sử dụng có kiểm soát |
| `P3` | Tối ưu hoặc mở rộng tùy chọn |

### 0.3. Quy tắc cập nhật

- Không xóa finding hay work item đã bị từ chối; chuyển trạng thái và ghi lý do.
- Mọi thay đổi phạm vi, API policy hoặc release policy phải có một entry trong Decision Log.
- Work item chỉ được chuyển sang `Done` khi acceptance criteria đã được kiểm chứng.
- Mỗi lần cập nhật phải đổi `Cập nhật gần nhất` và thêm một dòng vào Change Log.
- Khi source thay đổi đáng kể, cập nhật repository baseline và đánh dấu những bằng chứng cần audit lại.
- Các con số heuristic như số lượng public declaration không được coi là ABI report chính thức.

---

## 1. Executive assessment

### 1.1. Kết luận

Boardy có một vision tốt và khác biệt: dùng một runtime orchestration thống nhất để ghép các capability iOS thành flow, giảm dependency trực tiếp giữa module và cho phép thay đổi composition mà không đưa business logic vào lớp tích hợp.

Metaphor Board–Motherboard dễ truyền đạt. `IOInterface`, `BoardProducer`, `ModulePlugin`, flow DSL, gateway barrier và task boards đều giải quyết các vấn đề có thật trong ứng dụng iOS lớn.

Tuy nhiên, implementation và productization chưa theo kịp lời hứa kiến trúc:

- Type safety mới chủ yếu tồn tại ở facade; transport trung tâm vẫn dựa trên `Any?` và runtime cast.
- Lifecycle stateless chưa được enforce bằng state machine hoặc activation identity.
- Concurrency contract chưa rõ; strict concurrency phát hiện nhiều điểm sẽ trở thành lỗi trong Swift 6.
- Test target hiện không biên dịch và CI không còn phản ánh toolchain hiện tại.
- Tài liệu có nhiều thế hệ API và hướng dẫn mâu thuẫn.
- Distribution chỉ dựa trên CocoaPods trong khi chưa có Swift Package Manager.
- Release, security và community governance chưa đạt baseline của một dự án open source đáng tin cậy.

**Execution update 2026-07-14:** các nhận định trên là audit baseline. Option A Tasks 0–8 đã khôi phục test target, cố định API baseline và hoàn tất correctness/locking regressions với full suite 59/59. OSS governance/reproducible-tooling baseline và single-owner `CODEOWNERS` đã được thêm. Requester đã chuyển toàn bộ MainActor/Swift 6 isolation và backup continuity khỏi 1.61.0; Gate A1 được approve để triển khai iOS 14 metadata, SwiftPM Boardy và release gates.

### 1.2. Maturity verdict

Boardy hiện phù hợp với nhãn:

> **Incubating internal framework — usable only through a controlled pilot after P0 hardening.**

Boardy chưa nên được công bố là framework mặc định hoặc bắt buộc cho toàn tổ chức ở trạng thái hiện tại.

### 1.3. Hướng chiến lược được khuyến nghị nhưng chưa phê duyệt

Khuyến nghị là chiến lược staged evolution:

1. Khôi phục trust cho 1.x: build, test, CI, SwiftPM, correctness và documentation.
2. Harden lifecycle và concurrency mà không phá API hàng loạt.
3. Xây typed core cho Boardy 2, giữ compatibility bridge cho 1.x.
4. Chạy pilot trước khi nâng maturity level trong tổ chức.

Không khuyến nghị rewrite toàn bộ ngay lập tức. Một rewrite đồng thời core, API, concurrency, packaging và samples sẽ làm mất khả năng đối chiếu hành vi, kéo dài thời gian không có bản phát hành tin cậy và tăng migration risk.

### 1.4. Maturity scorecard

Điểm là judgment từ audit, không phải benchmark tiêu chuẩn hóa.

| Hạng mục | Hiện tại | Mục tiêu tối thiểu để `Recommended` | Nhận định |
|---|---:|---:|---|
| Vision và product value | 8/10 | 8/10 | Có vấn đề rõ ràng để giải quyết |
| Conceptual architecture | 7/10 | 8/10 | Metaphor và primitive tốt, boundary cần làm rõ |
| Modularization | 7/10 | 8/10 | IO/implementation split và plugin direction hợp lý |
| Type safety và API | 4/10 | 8/10 | Generic facade nhưng runtime transport chưa typed |
| Source correctness | 5/10 | 8/10 | Code nhỏ và đọc được nhưng còn lỗi cụ thể |
| Lifecycle ownership | 4/10 | 8/10 | Convention nhiều hơn enforcement |
| Swift concurrency | 2/10 | 8/10 | Chưa có isolation contract |
| Testing và CI | 2/10 | 8/10 | Test target đang fail compile; CI lỗi thời |
| Documentation và DX | 4/10 | 8/10 | Nội dung nhiều nhưng phân mảnh và mâu thuẫn |
| Release và OSS governance | 2/10 | 8/10 | Thiếu SPM, changelog, security và automation |
| Organizational adoption | 3/10 | 8/10 | Chưa có pilot gate, owner model và support policy |
| **Tổng thể** | **~4.5/10** | **>=8/10** | Có tiềm năng tốt nhưng cần hardening có hệ thống |

---

## 2. Scope, methodology và mức tin cậy

### 2.1. Phạm vi đã đọc

Audit bao gồm:

- Root documentation và toàn bộ tài liệu trong `docs/`.
- Local repository UIComposable ở phạm vi package feasibility cho Boardy/Composable.
- `AGENTS.md`, `.claude/CLAUDE.md` và các development instructions liên quan.
- Toàn bộ 64 file Swift trong `Boardy/`, khoảng 6.448 dòng.
- 15 file test với 33 test methods.
- Example application và các module Authentication, Dashboard, EmployeeManagement.
- Podspec, Podfile, Xcode schemes, Travis configuration, scripts và git hooks.
- Git history, tags, public GitHub repository, GitHub releases và CocoaPods page.
- Structural dependency và impact analysis bằng CodeGraph.
- Build và test verification qua Xcode workspace.

### 2.2. Phương pháp

1. Reconstruct vision từ tài liệu, API naming và examples.
2. Trace activation, flow, output, command, completion và plugin registration qua source.
3. So sánh implementation với các nguyên tắc được công bố: stateless, type-safe, separated và plug-and-play.
4. Kiểm tra lifecycle, ownership, global state, synchronization và Swift concurrency.
5. Kiểm tra test quality, CI, package metadata, release process và open-source hygiene.
6. Xác nhận các finding cấu trúc qua CodeGraph và các finding runtime/toolchain qua Xcode build/test.

### 2.3. Mức tin cậy của finding

| Nhãn | Ý nghĩa |
|---|---|
| `Confirmed` | Được quan sát trực tiếp trong source, build, test hoặc public repository |
| `Design risk` | Cấu trúc hiện tại tạo rủi ro hợp lý nhưng cần test/production evidence để định lượng |
| `Public gap` | Thiếu artifact hoặc quy trình có thể xác nhận từ repository công khai |
| `Hypothesis` | Cần một spike hoặc regression test trước khi coi là defect |

### 2.4. Giới hạn

Audit chưa có:

- Crash, leak hoặc performance telemetry từ app production.
- Danh sách consumer thực tế và version họ đang sử dụng.
- Phỏng vấn developer đã triển khai Boardy trong các dự án lớn.
- Kết quả Thread Sanitizer, Instruments, stress test hoặc API digester baseline.
- Legal approval cho dependency/license policy.

Các hạng mục này được chuyển thành candidate work items thay vì được giả định là đã biết.

---

## 3. Vision và product positioning

### 3.1. Vision hiện tại

[README](../README.md#why-boardy) định nghĩa hai nguyên tắc chính:

1. Giảm và cô lập dependency giữa các component.
2. Dùng một bộ protocol thống nhất để component có thể giao tiếp và thay thế nhau.

Board được mô tả là business unit độc lập, ưu tiên stateless. Motherboard là central orchestrator. `IOInterface` cung cấp contract type-safe. Controller sở hữu business/UI logic còn Board chỉ làm orchestration glue.

Đây là vision hợp lý cho ứng dụng iOS có nhiều feature team và flow thay đổi thường xuyên.

### 3.2. Positioning đề xuất

Tagline đề xuất:

> **Boardy is a typed, lifecycle-aware orchestration framework for modular iOS applications.**

“Microservices for mobile” nên được dùng như analogy hoặc lịch sử thiết kế, không nên là product category chính. Module trong cùng một iOS binary không có process isolation, independent deployment và failure boundary như server-side microservice.

### 3.3. Mô hình khái niệm đích

| Khái niệm | Định nghĩa đích | Không nên trở thành |
|---|---|---|
| Board | Stateless capability entry point hoặc flow adapter | View controller owner, business service hoặc mutable feature store |
| Motherboard | Scoped lifecycle and flow coordinator | Global event bus, service locator hoặc god object |
| IO contract | Public API ổn định của capability | Wrapper generic nhưng bên dưới silent-cast `Any?` |
| Plugin | Composition-time registration và dependency assembly | Runtime singleton chứa global mutable state |
| Bus | Typed local communication channel có lifetime rõ | Subscription store tăng vô hạn qua repeated activation |
| Barrier | Explicit precondition cho activation | Hidden global state hoặc implicit navigation policy |

### 3.4. Non-goals đề xuất

Boardy không nên cố trở thành:

- DI container tổng quát.
- Business logic architecture bắt buộc.
- State-management framework.
- Navigation framework thay thế hoàn toàn UIKit/SwiftUI navigation.
- Cross-process microservice runtime.
- Reactive framework riêng.

Ranh giới này giúp API nhỏ hơn và tránh để Motherboard hấp thụ mọi concern của ứng dụng.

---

## 4. Baseline snapshot

### 4.1. Repository

| Chỉ số | Baseline |
|---|---:|
| Swift files trong framework | 64 |
| Framework Swift LOC | ~6.448 |
| Test files | 15 |
| Test methods | 33 |
| Tài liệu chuyên đề trong `docs/` | 7 |
| Current version | 1.60.1 |
| Minimum iOS trong podspec | 12.0 |
| Distribution | CocoaPods only |
| SwiftPM manifest | Không có |
| GitHub Actions workflows | Không có |
| License | MIT |
| Public/open declaration matches | ~504; heuristic, không phải ABI count |
| Public documentation comments | ~116 dòng `///`; heuristic |

### 4.2. Toolchain metadata đang không nhất quán

| Nguồn | Giá trị |
|---|---|
| README badge/instructions | Swift 5.9 |
| `.swiftformat` | Swift 5.5 |
| `Boardy.podspec` | Swift 5 |
| Main Xcode targets | Swift 5.0 |
| Một số test configurations | Swift 4.0 |
| CocoaPods public page | iOS 10+, Xcode 11+, Swift 5.1+ |

Một framework open source cần một compatibility matrix duy nhất và được CI enforce.

### 4.3. Pre-execution build verification ngày 2026-07-14

Môi trường kiểm chứng:

- Workspace: `Example/Boardy.xcworkspace`
- Framework scheme: `Boardy`
- Test scheme: `Boardy_Tests`
- Configuration: Debug
- Simulator: iPhone 17, iOS 26.4
- Local build root: `.build-local/` trong repo trên external drive; Git và Claude index đều ignore
- Derived data: `.build-local/DerivedData/<verification-row>`
- Package source checkout: `.build-local/SourcePackages`
- Result bundles/logs: `.build-local/Results`
- Xcode package resolution: `-clonedSourcePackagesDirPath` + `-disablePackageRepositoryCache`; không dùng empty custom `-packageCachePath` vì Xcode 26.4.1 trả package graph rỗng và thiếu Cwl products

Kết quả:

| Check | Kết quả | Evidence |
|---|---|---|
| Framework build | Passed trong khoảng 18,2 giây | Build với `SWIFT_STRICT_CONCURRENCY=complete` |
| Strict concurrency | Warning | Nhiều warning trong source Boardy được compiler ghi nhận sẽ thành lỗi ở Swift 6 language mode |
| Test build/run | Failed trước khi chạy test | [`StaticStorage` không còn tồn tại](../Example/Tests/AttachableTests.swift#L25) |
| Warning volume | 45 warnings toàn project/dependencies trong lần build | Cần tách Boardy-owned warning khỏi dependency warning trong CI |

Kết luận tại audit baseline: “framework build được” chỉ đúng trong Swift 5 compatibility mode; chưa thể suy ra test suite hoặc Swift 6 readiness.

#### 4.3.1. Option A Tasks 0–8 checkpoint

| Check | Kết quả | Evidence |
|---|---|---|
| Immutable `1.60.1` public API baseline | Passed; independently committed before Boardy source mutation | Commit `53664db10ae92924a6a7ca97bf0d0b906d0a3cca`; [`BASELINE_PROVENANCE.md`](api/BASELINE_PROVENANCE.md) |
| API verifier self-check | PASS | `.build-local/Results/boardy-1.60.1-baseline-self-verification.md` |
| Review regressions — RED | 3 tests, 5 failures | `.build-local/Results/ReviewRegressions-RED.xcresult` |
| Review regressions — GREEN | 3/3 passed | `.build-local/Results/ReviewRegressions-GREEN-2.xcresult` |
| Full Boardy suite after corrective batch | 59/59 passed, 0 failed | `.build-local/Results/BoardyFullSuite-PostReview.xcresult` |

Executable evidence used only destination `714C9786-1327-41DF-A093-73359C82E0C2` (iPhone 17, iOS 26.4 runtime; xcresult metadata reports patch version 26.4.1). Không simulator/device nào khác được target. Đây là checkpoint cho Tasks 0–8, không thay final joined review trong Task 13 và không chứng minh Swift 6/iOS 14/package/release readiness.

### 4.4. Public release snapshot

Tại thời điểm audit:

- [CocoaPods](https://cocoapods.org/pods/Boardy) công bố Boardy `1.60.1`.
- [GitHub repository](https://github.com/congncif/boardy) có 16 stars, 2 issues, 0 open pull requests và chưa có security/quality configuration công khai.
- [GitHub Releases](https://github.com/congncif/boardy/releases) chỉ có release `1.34.1`, dù repository có nhiều tag mới hơn.
- Lịch sử commit tập trung gần như hoàn toàn vào một maintainer, tạo bus-factor risk.

Các con số community không được dùng để suy luận chất lượng source, nhưng là evidence về adoption và maintainer capacity hiện tại.

---

## 5. Điểm mạnh cần bảo toàn

### S-001 — Mental model dễ truyền đạt

Board–Motherboard tạo ra vocabulary đơn giản cho capability, composition và workflow. Đây là lợi thế adoption đáng kể so với một tập hợp coordinator/registry abstraction rời rạc.

### S-002 — Tách orchestration khỏi controller architecture

Boardy không bắt buộc feature dùng MVC, VIP, Clean Architecture hoặc SwiftUI. Board đóng vai trò integration adapter; controller và module vẫn có thể chọn kiến trúc nội bộ.

### S-003 — IO/implementation module boundary

[Boardy Modularization](Boardy%20Modularization.md#iointerface) mô tả việc tách public IO target khỏi implementation plugin target. Đây là boundary tốt cho tổ chức lớn vì consumer có thể compile chỉ với contract.

### S-004 — Lazy registration và plugin composition

`BoardProducer` cho phép lazy construction. `ModulePlugin` và `LauncherPlugin` tạo được một composition root tương đối rõ và có thể đóng gói dependency wiring theo module.

### S-005 — Flow, barrier và task primitives giải quyết nhu cầu thật

Activation barrier, gateway barrier, chained flow, combined flow, task board và URL opener phản ánh nhiều tình huống thực tế của ứng dụng thay vì chỉ cung cấp abstractions tối thiểu.

### S-006 — Core có kích thước còn kiểm soát được

Khoảng 6.448 dòng Swift là phạm vi vẫn có thể audit, test và refactor theo từng lớp mà không cần rewrite toàn bộ.

### S-007 — Nhận thức về reference lifetime

Weak delegate, weak target box và weak context cho thấy thiết kế đã chủ động tránh một số retain cycle phổ biến. Hướng này nên được giữ, nhưng cần bổ sung ownership contract và lifetime tests.

### S-008 — License và lịch sử phát triển

MIT license, nhiều version tag, examples và test assets tạo nền tảng tốt để chuyển từ internal framework sang một open-source product có governance.

---

## 6. Mức đáp ứng so với định hướng công bố

| Định hướng | Mức đáp ứng | Evidence chính | Khoảng trống |
|---|---|---|---|
| Isolated modules | Khá | IO target, ModulePlugin, lazy BoardProducer | UIKit/core coupling, broad umbrella dependency, global state |
| Type-safe communication | Một phần | Generic `BoardInput`, typed activation/flow facade | `Any?`, runtime cast, silent Release mismatch |
| Stateless Board | Một phần | Weak context, README guidance | Content lookup, repeated subscriptions, không có lifecycle state machine |
| Separation of concerns | Khá | Board/controller split, event buses | Samples đưa navigation/business decision vào UI state |
| Plug-and-play composition | Khá | LauncherPlugin, BoardRegistration, ServiceMap | Global singleton, lifetime assumptions, URL selection ambiguity |
| Scalable execution | Thấp | Một số synchronized collections | Caller-controlled legacy contract; chưa có isolation model dài hạn, compound race và cancellation ambiguity |
| Enterprise maintainability | Thấp | Small codebase, subspecs | CI/test/API compatibility/documentation chưa đủ |
| Open-source readiness | Thấp | MIT, public repo, CocoaPods | Thiếu SPM, governance, security, changelog, release automation |

---

## 7. Finding register

### 7.1. Architecture và API

| ID | Priority | Confidence | Finding | Impact | Evidence |
|---|---|---|---|---|---|
| `ARCH-001` | P0 | Confirmed | Type safety chỉ ở facade; transport dùng `Any?` | Mismatch bị phát hiện runtime, có thể silent trong Release | [`BoardDelegate`](../Boardy/Core/BoardType/BoardType.swift#L12), [`BoardInputModel`](../Boardy/Core/BoardType/BoardInputModel.swift#L10), [`BoardCommandModel`](../Boardy/Core/BoardType/InteractableBoard.swift#L10) |
| `ARCH-002` | P1 | Design risk | Motherboard có thể trở thành service locator/event bus trung tâm | Coupling ẩn và khó test khi adoption tăng | `sendToMotherboard` có blast radius lớn qua core, flows, tests và samples |
| `ARCH-003` | P0 | Confirmed | Lifecycle không có state machine hoặc activation identity | Double completion, stale callback và repeated activation khó kiểm soát | [`complete`](../Boardy/Core/BoardType/BoardType.swift#L63) |
| `ARCH-004` | P1 | Confirmed | Board có API tìm lại watched content/controller | Mâu thuẫn với stateless orchestration boundary | [`availableWatchedContents`](../Boardy/Core/Board/Board.swift#L74) |
| `ARCH-005` | P1 | Confirmed | Core phụ thuộc UIKit ở nhiều protocol và utility | Khó headless-test, khó chia package, không portable | [`InstallableBoard`](../Boardy/Core/BoardType/InstallableBoard.swift#L8) |
| `ARCH-006` | P1 | Confirmed | Public API surface rộng so với kích thước core | Tăng compatibility burden và giảm khả năng refactor | Khoảng 504 `public`/`open` matches |
| `ARCH-007` | P1 | Confirmed | Error/diagnostic dựa nhiều vào `print`, assertion và precondition | Không có structured observability; Release behavior không nhất quán | [`DebugLog`](../Boardy/Core/Utils/DebugLog.swift), [`PluginLauncher.shared`](../Boardy/ModulePlugin/PluginLauncher.swift#L146) |
| `ARCH-008` | P1 | Confirmed | Missing UI context trả về controller/window rỗng sau assertion | Release có thể tiếp tục với UI object sai thay vì fail rõ | [`InstallableBoard`](../Boardy/Core/BoardType/InstallableBoard.swift#L17) |
| `ARCH-009` | P1 | Confirmed | `AdapterBoard` thay destination delegate và không chuyển context | Có thể phá delegate ownership hoặc activation behavior của wrapped board | [`AdapterBoard`](../Boardy/ComponentKit/AdapterBoard.swift#L19) |
| `ARCH-010` | P2 | Design risk | `AttachableObject` được mở rộng rất rộng trên NSObject/global storage | Namespace collision, nondeterministic lookup và khó cô lập test | [`Attachable`](../Boardy/Attachable/Attachable.swift#L22) |

### 7.2. Correctness và lifecycle

| ID | Priority | Confidence | Finding | Impact | Evidence |
|---|---|---|---|---|---|
| `COR-001` | P0 | Confirmed | `activateAllBoards` dùng `return` khi thiếu input | Dừng vòng lặp, các board còn lại không được activate | [`MotherboardType+Interface`](../Boardy/Composable/MotherboardType+Interface.swift#L28) |
| `COR-002` | P0 | Confirmed | Combined flow gọi user handler bên trong serial `sync` | Reentrant handler có thể deadlock | [`OutputCombinedFlow.doNext`](../Boardy/Core/BoardType/CombinedFlow.swift#L93) |
| `COR-003` | P0 | Confirmed | Combined flow lưu optional value vào `[BoardID: Any]` | `nil` xóa key nên flow có thể không bao giờ fulfill | [`_outputValues`](../Boardy/Core/BoardType/CombinedFlow.swift#L83) |
| `COR-004` | P0 | Design risk | Block task callback không được guard exactly-once | Double callback có thể xử lý result/completion nhiều lần | [`finishExecuting`](../Boardy/ComponentKit/BlockTaskBoard.swift#L365) |
| `COR-005` | P1 | Confirmed | Block task cancellation và shared completion iteration chưa có transaction boundary rõ | Race và completion status không ổn định dưới concurrent load | [`BlockTaskBoard`](../Boardy/ComponentKit/BlockTaskBoard.swift#L326) |
| `COR-006` | P1 | Confirmed | Repeated Login activation nối thêm cable vào cùng Bus | Handler có thể chạy lặp và cable tích lũy | [`LoginBoard`](../Example/submodules/Authentication/Sources/Components/Microboards/Login/LoginBoard.swift#L40) |
| `COR-007` | P1 | Confirmed | CurrentUser board thêm observer mỗi lần activate nhưng không thể hiện teardown | Duplicate notification/lifetime leak risk | [`CurrentUserBoard`](../Example/submodules/Authentication/Sources/Components/Microboards/CurrentUser/CurrentUserBoard.swift#L30) |
| `COR-008` | P1 | Confirmed | Action sheet không cấu hình popover anchor | Có thể crash trên iPad khi present `.actionSheet` | [`AlertBoard`](../Boardy/ComponentKit/AlertBoard.swift#L63) |
| `COR-009` | P1 | Confirmed | Class-based `ModuleBuilderPlugin` được giữ weak trong `ObjectBox` | Plugin có thể deallocate trước lazy board construction | [`ModulePlugin`](../Boardy/ModulePlugin/ModulePlugin.swift#L120), [`ObjectBox`](../Boardy/Core/Board/Bus.swift#L30) |
| `COR-010` | P1 | Confirmed | URL opener trả về tất cả matched handler names trước/không phụ thuộc async selection result | Return contract “handled plugins” có thể không đúng thực tế | [`handleOpen`](../Boardy/ModulePlugin/PluginLauncher.swift#L302) |
| `COR-011` | P1 | Confirmed | `GatewayBarrierRegistration.exempt` chứa ký tự zero-width | Autocomplete và source usage khó đoán; migration phức tạp | [`exempt`](../Boardy/ModulePlugin/GatewayBarrierRegistration.swift#L29) |

### 7.3. Concurrency và Swift 6

| ID | Priority | Confidence | Finding | Impact | Evidence |
|---|---|---|---|---|---|
| `CON-001` | P0 | Confirmed | UI orchestration chưa có explicit isolation/executor contract | Swift 6 errors và UI access từ sai executor | Strict-concurrency build warnings trong AlertBoard, NoBoard và InstallableBoard |
| `CON-002` | P0 | Confirmed | Global mutable barrier cache | Shared application state không có actor isolation | [`ActivationBarrierFactory.cache`](../Boardy/Core/BoardType/ActivatableBarrierBoard.swift#L53) |
| `CON-003` | P0 | Confirmed | Global mutable attachment table | NSMapTable không có documented synchronization ở đây | [`AttachableStaticStorage`](../Boardy/Attachable/Attachable.swift#L22) |
| `CON-004` | P0 | Confirmed | Mutable singleton launcher | Race, test contamination và non-resettable global lifecycle | [`PluginLauncher.sharedInstance`](../Boardy/ModulePlugin/PluginLauncher.swift#L137) |
| `CON-005` | P0 | Design risk | Safe collections chỉ atomic cho operation riêng lẻ | Check-then-act vẫn có thể race, ví dụ barrier activation | Safe collection và barrier activation audit |
| `CON-006` | P0 | Confirmed | BoardID/MainOptions và closure captures chưa đáp ứng Sendable | Compiler cảnh báo sẽ lỗi ở Swift 6 language mode | Strict-concurrency build |
| `CON-007` | P1 | Confirmed | Operation subclass chưa restate inherited `@unchecked Sendable` | Swift 6 migration blocker và unsafe assumption chưa document | `BlockTaskExecutionOperation` build warning |
| `CON-008` | P1 | Design risk | Callback queue/executor không được định nghĩa trong public contract | Consumer không biết khi nào cần hop sang MainActor | Public protocol/documentation audit |

### 7.4. Tests và quality engineering

| ID | Priority | Confidence | Finding | Impact | Evidence |
|---|---|---|---|---|---|
| `QA-001` | P0 | Confirmed | Test target không compile | Không có regression signal | [`AttachableTests`](../Example/Tests/AttachableTests.swift#L25) |
| `QA-002` | P1 | Confirmed | Nhiều test dùng real-time `asyncAfter` và timeout nhiều giây | Flaky, chậm và khó tái hiện | [`BlockTaskTests`](../Example/Tests/BlockTaskTests.swift), [`FlowTests`](../Example/Tests/FlowTests.swift) |
| `QA-003` | P1 | Confirmed | Test chủ yếu happy path | Không bảo vệ double completion, reentrancy, failure, Release mismatch và races | Inventory 33 test methods |
| `QA-004` | P1 | Confirmed | Không có leak/lifetime assertions; example scheme tắt leak detection | Lifecycle promise chưa được kiểm chứng | [`Boardy-Example.xcscheme`](../Example/Boardy.xcodeproj/xcshareddata/xcschemes/Boardy-Example.xcscheme#L122) |
| `QA-005` | P2 | Public gap | Không có performance benchmark | Không có baseline cho dispatch/activation/memory overhead | Repository inventory |
| `QA-006` | P1 | Public gap | Không có API/ABI compatibility check | Public surface lớn nhưng breaking change không được tự động phát hiện | Repository/CI inventory |
| `QA-007` | P2 | Confirmed | Có ít nhất một empty placeholder test | Số lượng test không phản ánh đầy đủ assertion quality | `PluginTests.testExample` |

### 7.5. Documentation và developer experience

| ID | Priority | Confidence | Finding | Impact | Evidence |
|---|---|---|---|---|---|
| `DOC-001` | P0 | Confirmed | README stateless/Event Bus mâu thuẫn với guide stateful/RxSwift | Consumer học hai programming models khác nhau | [README](../README.md#core-concepts), [UsageGuide-vi](UsageGuide-vi.md) |
| `DOC-002` | P0 | Confirmed | Toolchain/platform/version metadata mâu thuẫn | Không xác định được compatibility contract | README, `.swiftformat`, podspec và Xcode settings |
| `DOC-003` | P1 | Confirmed | README của example modules chỉ là template placeholder | Example không đóng vai trò reference implementation | [`Authentication README`](../Example/submodules/Authentication/README.md) và hai module còn lại |
| `DOC-004` | P1 | Public gap | Không có DocC API reference và tutorial được version hóa | Public API khó discover và không gắn với release | Repository inventory |
| `DOC-005` | P1 | Confirmed | AGENTS hướng dẫn `swift build/test` nhưng không có `Package.swift` | Hướng dẫn canonical không chạy được | [`AGENTS.md`](../AGENTS.md#build-verification) |
| `DOC-006` | P1 | Confirmed | README/code sử dụng EventBus/Bus và path Plugins/ModulePlugin không nhất quán | Naming drift làm onboarding khó hơn | README/AGENTS/source comparison |
| `DOC-007` | P2 | Confirmed | Nhiều deprecated example files vẫn được track | Tăng search noise và nguy cơ copy API cũ | 61 tracked paths dưới `Example/Boardy/Deprecated` |

### 7.6. Distribution, release và open-source governance

| ID | Priority | Confidence | Finding | Impact | Evidence |
|---|---|---|---|---|---|
| `REL-001` | P0 | Confirmed | Travis dùng Xcode 7.3 | CI không đại diện cho source hiện tại | [`.travis.yml`](../.travis.yml#L5) |
| `REL-002` | P0 | Public gap | Không có GitHub Actions | Không có visible required checks | Repository inventory |
| `REL-003` | P0 | Public gap | Không có `Package.swift` | Không cài được qua SwiftPM | Repository inventory |
| `REL-004` | P0 | Confirmed | CocoaPods 1.60.1 nhưng GitHub release dừng ở 1.34.1 | Release notes và migration history không audit được | [CocoaPods](https://cocoapods.org/pods/Boardy), [GitHub Releases](https://github.com/congncif/boardy/releases) |
| `REL-005` | P0 | Public gap | Thiếu CHANGELOG, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, SUPPORT và governance | Consumer/maintainer không có operating contract | Repository inventory |
| `REL-006` | P0 | Confirmed | Template scripts clone mutable repository head, không pin/checksum | Supply-chain và reproducibility risk | [`install-template.sh`](../tools/install-template.sh#L10), [`init-module.sh`](../tools/init-module.sh#L20) |
| `REL-007` | P1 | Confirmed | `UIComposable` dependency không có version constraint | Dependency resolution không reproducible | [`Boardy.podspec`](../Boardy.podspec#L51) |
| `REL-008` | P1 | Confirmed | `claude-dangerous.sh` chạy với skipped permissions | Không phù hợp để ship như project utility mặc định | Audit-baseline file; removed in Task 12 |
| `REL-009` | P1 | Public gap | Không có SBOM, provenance, dependency review hoặc signed-release policy | Enterprise supply-chain posture chưa đủ | Repository/release inventory |
| `REL-010` | P1 | Confirmed | Maintainer concentration cao | Bus factor và release continuity risk | Git history audit |
| `REL-011` | P0 | Confirmed | CocoaPods trunk dự kiến read-only từ 2026-12-02 | Sau mốc này không thể publish version mới qua trunk theo kế hoạch hiện tại | [CocoaPods plan](https://blog.cocoapods.org/CocoaPods-Specs-Repo/) |
| `REL-012` | P2 | Confirmed | Podspec homepage trỏ tới profile thay vì repository | Metadata quality và discoverability kém | [`Boardy.podspec`](../Boardy.podspec#L11) |

---

## 8. Deep dive vào các blocker chính

### 8.1. Type safety: lời hứa và thực tế

#### Hiện trạng

Typed API như `BoardInput<Input>`, guaranteed input/output board và `IOInterface` mang lại compile-time guidance ở call site. Nhưng mọi message cuối cùng được đóng gói thành `Any?`, đi qua `BoardDelegate`, sau đó cast về associated type.

Một command sai type tại [`GuaranteedCommandBoard.interact`](../Boardy/Core/BoardType/InteractableBoard.swift#L33) chỉ assertion trong Debug và `return` trong Release.

#### Tác động

- Không thể chứng minh end-to-end contract safety.
- Một thay đổi contract có thể compile ở producer nhưng mất message ở runtime.
- Failure mode khác nhau giữa Debug và Release.
- Debugging phụ thuộc log/assertion thay vì typed error.

#### Hướng cải thiện

1. 1.x: thêm structured mismatch diagnostics, test Release behavior và document compatibility boundary.
2. 2.x: typed route/envelope với `Input: Sendable` và `Output: Sendable`.
3. Giữ adapter `AnyBoardRoute` cho 1.x nhưng đánh dấu deprecated.
4. Không expose `Any?` trong API mới.

#### Exit criteria

- New API không cần runtime cast ở consumer-facing path.
- Contract mismatch không bị silent trong Release.
- API compatibility test phát hiện thay đổi Input/Output contract.
- Có migration guide từ IOInterface 1.x sang typed route.

### 8.2. Lifecycle: convention chưa đủ

#### Hiện trạng

Board được khuyến nghị stateless nhưng framework không ghi nhận activation state. `complete()` chỉ gửi một action về Motherboard. Không có activation token để phân biệt callback thuộc lần activate nào.

Repeated activation có thể nối thêm bus cable hoặc observer, như LoginBoard và CurrentUserBoard trong sample.

#### Hướng cải thiện

Định nghĩa lifecycle tối thiểu:

```text
registered -> activating -> active -> completing -> completed
                   |                         |
                   +------ cancelled -------+
```

Mỗi activation có một `ActivationID`. Completion phải idempotent theo activation. Callback từ activation cũ phải bị bỏ qua có diagnostics, không được hoàn thành activation mới.

#### Exit criteria

- Double completion không crash và không remove sai board.
- Repeated activation có semantics được document và test.
- Subscription ownership gắn với activation hoặc board lifetime.
- Leak/lifetime tests xác nhận board, controller và bus cable được release.

### 8.3. Concurrency: giữ contract 1.61, thiết kế isolation ở plan sau

#### Quyết định cho 1.61.0

- `Board`, `Motherboard`, flow registry, plugin composition và URL routing giữ synchronous
  caller-controlled execution hiện tại.
- Không thêm `@MainActor`, global actor, main-thread runtime precondition hoặc automatic queue hop.
  UIKit callers tiếp tục chịu trách nhiệm gọi từ main thread theo UIKit contract.
- Background task execution tiếp tục được hỗ trợ. Toàn bộ terminal sequence của `BlockTaskBoard`
  giữ legacy completion executor và observable ordering.
- Shared mutable storage đã xác định dùng lock/transaction nhỏ và không gọi callback trong lock.
- Không thêm public `Sendable` constraints hoặc compatibility carrier chỉ để đạt Swift 6 language
  mode.

#### Follow-up độc lập

MainActor chỉ là một option trong
[`MainActor/Swift 6 follow-up`](superpowers/plans/2026-07-14-boardy-mainactor-swift6-follow-up.md),
không còn là kiến trúc đã chọn cho 1.61. Follow-up phải inventory call sites, chọn isolation model,
định nghĩa executor migration, đánh giá source/behavior break và quyết định minor/major scope trước
khi sửa source.

#### Không khuyến nghị

- Đánh dấu hàng loạt `@unchecked Sendable` để làm hết warning mà không chứng minh invariants.
- Thêm synchronous main-thread trap hoặc queue hop phía sau API hiện hữu mà không có consumer
  migration.
- Mỗi Motherboard là một actor độc lập ngay trong 1.x mà chưa đánh giá `await` và reentrancy
  semantics mới.

#### Exit criteria của follow-up

- Một isolation/executor ADR được phê duyệt bằng consumer evidence.
- Public API và behavioral compatibility được phân loại trước implementation.
- Swift 6 language-mode build, executor tests và stress/TSan rows xanh theo matrix được duyệt.

### 8.4. Build trust và release trust

Một framework không thể được xem là reliable khi test target không compile và public release notes dừng xa hơn current package version.

Minimum trust restoration gồm:

- CI build/test trên supported Xcode matrix.
- SwiftPM smoke test trong clean sample consumer.
- CocoaPods lint trong giai đoạn compatibility.
- Changelog và GitHub release cho mỗi version.
- API compatibility report.
- Security policy và reproducible dependency pins.

---

## 9. Target architecture candidate

Phần này là design candidate, chưa phải quyết định implementation.

### 9.1. Package products

| Product | Trách nhiệm | Dependency được phép |
|---|---|---|
| `BoardyContracts` | `BoardID`, typed routes, IO contracts, lifecycle/error value types | Foundation |
| `BoardyCore` | Registry, activation state machine, flow engine, scoped coordinator | BoardyContracts |
| `BoardyUIKit` | UI context, UIKit presentation, UIKit-specific barriers | BoardyCore + UIKit |
| `BoardyTasks` | Async task, cancellation, retry, exactly-once completion | BoardyCore |
| `BoardyPlugins` | Module registration và composition root | BoardyCore |
| `BoardyTesting` | Test motherboard, spies, fake clock, lifecycle assertions | BoardyCore |
| `BoardyComposable` | Optional UIComposable adapter | BoardyUIKit + version-pinned UIComposable |

### 9.2. Dependency direction

```text
BoardyContracts
      ^
      |
 BoardyCore
   ^   ^   ^
   |   |   |
UIKit Tasks Plugins
   ^
   |
Composable

BoardyTesting -> BoardyCore
```

`BoardyCore` không import UIKit. UI-specific defaults và presentation logic nằm trong `BoardyUIKit`.

### 9.3. Typed route model candidate

Khái niệm API:

```swift
public struct BoardRoute<Input: Sendable, Output: Sendable>: Sendable {
    public let id: BoardID
}
```

Mục tiêu của model này:

- Một route gắn BoardID, Input và Output thành một contract duy nhất.
- Activation không nhận raw `Any?`.
- Output handling không cần consumer cast.
- Route contract có thể nằm trong lightweight interface module.

Syntax cụ thể chỉ được quyết định sau RFC/prototype; đoạn code trên không phải committed API.

### 9.4. Compatibility strategy

- Không xóa API 1.x trong hardening releases.
- New typed core có bridge từ `BoardInputModel`/`BoardOutputModel` cũ.
- Deprecated API phải có replacement và migration example.
- Source/API breaking change chỉ phát hành trong major version. Minimum-platform change có thể phát hành ở minor theo project policy, nhưng phải có consumer inventory, compatibility disclosure và migration path rõ ràng.
- Duy trì một compatibility test app dùng API 1.x trong suốt chu kỳ Boardy 2 preview.

### 9.5. Diagnostics candidate

Thay `print`/emoji assertion bằng một abstraction tối thiểu:

- Event category: registration, activation, flow, completion, mismatch, cancellation.
- Severity: debug, notice, warning, error, fault.
- Metadata: BoardID, ActivationID, route, source, destination.
- Default adapter sang `OSLog`.
- Test sink để assert diagnostics.
- Không log raw URL hoặc sensitive payload mặc định.

---

## 10. Strategic options để quyết định

### Option A — Chỉ harden Boardy 1.x

**Phạm vi:** sửa correctness và shared-state races, thêm SPM/docs/release baseline, xác nhận Swift 5
compatibility trên Xcode hiện tại; giữ runtime `Any?`. MainActor/Swift 6 language mode thuộc
follow-up riêng.

**Ưu điểm:** migration cost thấp, sớm có bản ổn định.

**Nhược điểm:** không giải quyết triệt để lời hứa type safety; public API debt tiếp tục tồn tại.

**Phù hợp khi:** Boardy chủ yếu phục vụ một số app hiện hữu và không có capacity cho major-version program.

### Option B — Harden 1.x rồi phát triển 2.x theo từng lớp

**Phạm vi:** hoàn thành trust baseline cho 1.x, sau đó typed route, lifecycle state machine và package split dưới compatibility bridge.

**Ưu điểm:** cân bằng stability và architectural correction; có release value sớm; migration đo được.

**Nhược điểm:** trong một giai đoạn phải duy trì cả legacy và new API.

**Khuyến nghị:** đây là lựa chọn tốt nhất nếu mục tiêu là organizational adoption và open source lâu dài.

### Option C — Rewrite Boardy 2 từ đầu

**Phạm vi:** thiết kế lại toàn bộ core và chỉ giữ concept.

**Ưu điểm:** API sạch, không bị constraint bởi 1.x.

**Nhược điểm:** rủi ro behavior regression, migration lớn, thời gian dài không cải thiện release hiện tại, khó dùng production evidence để dẫn dắt design.

**Không khuyến nghị** trừ khi không còn consumer 1.x hoặc source hiện tại được chính thức đưa vào maintenance-only mode.

---

## 11. Candidate roadmap

Roadmap là sequencing proposal. Timeline giả định một nhóm nhỏ có owner ổn định; cần điều chỉnh sau khi biết capacity.

### Phase 0 — Decision and ownership baseline

**Mục tiêu:** xác định ai quyết định, ai maintain và phạm vi support.

**Candidate duration:** 1–2 tuần.

**Exit criteria:**

- `D-001` đến `D-006` được quyết định.
- Có technical/release owner; continuity risk và kế hoạch bổ sung backup được ghi rõ.
- Chọn Option A, B hoặc C.
- Có supported toolchain/platform matrix.
- Có danh sách consumer hiện hữu và version đang dùng.

### Phase 1 — Restore trust

**Mục tiêu:** một bản 1.x có thể build, test, install và release lặp lại.

**Candidate duration:** 2–6 tuần.

**Phạm vi candidate:**

- Sửa test compile và correctness P0.
- CI trên Xcode matrix.
- Swift Package Manager.
- Ghi nhận Swift 6 diagnostic baseline; không claim language-mode readiness.
- Canonical README/compatibility matrix.
- Changelog, security và release automation.
- Pin external dependencies/template inputs.

**Exit criteria:** Quality Gate G1.

### Phase 2 — Lifecycle and concurrency hardening

**Mục tiêu:** framework có execution/lifecycle contract rõ và test được.

**Candidate duration:** 1–3 tháng.

**Phạm vi candidate:**

- Isolation-model RFC; MainActor là một option cần consumer evidence, không phải quyết định mặc định.
- Activation state machine và idempotent completion.
- Deterministic tests, fake clock và lifetime tests.
- Structured diagnostics.
- Public API audit và API digester baseline.

**Exit criteria:** Quality Gate G2 và ít nhất một pilot module.

### Phase 3 — Boardy 2 typed core

**Mục tiêu:** khớp lời hứa type safety với runtime implementation.

**Candidate duration:** 3–6 tháng.

**Phạm vi candidate:**

- `BoardyContracts` và typed route RFC.
- Foundation-only `BoardyCore`.
- Async/cancellation contract.
- Compatibility bridge và migration tooling.
- DocC và reference applications.

**Exit criteria:** Quality Gate G3.

### Phase 4 — Organizational and public adoption

**Mục tiêu:** Boardy trở thành supported product thay vì source repository.

**Candidate duration:** 6–12 tháng, chạy chồng với Phase 3 khi phù hợp.

**Phạm vi candidate:**

- 2–3 production pilots.
- Maintainer program và support policy.
- Signed releases, SBOM và provenance.
- Public roadmap, issue templates và discussions.
- Adoption metrics và release cadence.

**Exit criteria:** Quality Gate G4.

---

## 12. Candidate backlog

### 12.1. Effort scale

| Effort | Diễn giải |
|---|---|
| `S` | Tối đa khoảng 1–2 ngày kỹ thuật sau khi scope rõ |
| `M` | Khoảng 3–5 ngày hoặc cần phối hợp nhỏ |
| `L` | Khoảng 1–3 tuần, nhiều file/subsystem |
| `XL` | Program nhiều tuần/tháng, cần RFC và migration |

Effort chỉ dùng để so sánh tương đối; chưa phải estimate cam kết.

### 12.2. Foundation và ownership

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `FOUND-001` Chỉ định technical/release owner | P0 | Done | S | Có quyền quyết định/release | Sole owner `congnc.if@gmail.com` / `@congncif`; backup continuity accepted and deferred |
| `FOUND-002` Inventory consumer/version đang dùng | P0 | Done for release disposition | M | Biết migration blast radius | Technical evidence captured; GitHub-only release is opt-in, later CocoaPods publication requires migrate/`< 1.61`/retire |
| `FOUND-003` Chọn strategic option A/B/C | P0 | Selected | S | Scope program rõ | `D-003` |
| `FOUND-004` Chốt support matrix | P0 | Selected | S | iOS/Swift/Xcode contract rõ | `DOC-002`, `D-004` |
| `FOUND-005` Thiết lập Decision Log/RFC workflow | P1 | In progress | S | Các quyết định kiến trúc có history | ADR-0001 lưu proposal đã deferred; follow-up cần ADR mới hoặc revision được duyệt |

### 12.3. Build, CI và distribution

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `BUILD-001` Sửa test target compile | P0 | Done | S | Test suite có thể chạy | Commit `dadf9a5`; full suite 59/59 |
| `BUILD-002` Thêm GitHub Actions build/test matrix | P0 | Proposed | M | Required checks tin cậy | `REL-001`, `REL-002` |
| `BUILD-003` Thêm `Package.swift` và products ban đầu | P0 | Selected | M/L | SwiftPM installation | `REL-003`, `D-006` |
| `BUILD-004` Thêm clean-consumer SPM smoke test | P0 | Selected | M | Xác minh package dùng ngoài repo | Sau `BUILD-003` |
| `BUILD-005` Duy trì `pod lib lint` trong transition | P1 | Selected | S | Không phá consumer CocoaPods hiện tại | `REL-011` |
| `BUILD-006` Đồng bộ Swift/platform metadata | P0 | Selected | S | Một compatibility contract | `DOC-002`, `FOUND-004` |
| `BUILD-007` Thiết lập Swift API digester baseline | P1 | Done | M | Detect source/API break | Immutable commit `53664db`; self-verifier PASS |
| `BUILD-008` Tách Boardy warnings khỏi dependency warnings | P1 | Proposed | S/M | CI ownership rõ | `CON-001`–`CON-007` |
| `BUILD-009` Bật warnings-as-errors theo staged policy | P1 | Proposed | M | Ngăn warning debt quay lại | Sau `BUILD-008` |

### 12.4. Correctness và lifecycle fixes

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `FIX-001` Sửa early `return` trong `activateAllBoards` | P0 | Done | S | Tất cả board được xử lý | Commit `a00b840`; lifecycle 3/3 |
| `FIX-002` Refactor CombinedFlow không gọi handler trong lock | P0 | Done | M | Không reentrant deadlock | Commit `dd78e10`; CombinedFlow 3/3 |
| `FIX-003` Thiết kế representation cho combined optional output | P0 | Done | M | `nil` là value hợp lệ | Commit `dd78e10`; boxed optional regression |
| `FIX-004` Guard BlockTask completion exactly-once | P0 | Done | M/L | Không double result/completion | Commit `b755a0f`; deterministic BlockTask 12/12 × 5 |
| `FIX-005` Làm rõ BlockTask cancellation semantics | P1 | Done | L | Consistent cancellation/status | Commit `b755a0f`; reasoned terminal/canceler regressions |
| `FIX-006` Thêm API `exempt` sạch và deprecate symbol zero-width | P1 | Done | S | API discoverable, migration an toàn | Commit `f428427`; plugin/launcher 7/7 |
| `FIX-007` Cấu hình action-sheet popover hoặc require presentation anchor | P1 | Done | S | Không crash trên iPad | Commit `d9cd462`; popover regressions |
| `FIX-008` Thay synthetic context fallback bằng typed failure policy | P1 | Proposed | M | Không tiếp tục với UI object sai | `ARCH-008`, `D-010` |
| `FIX-009` Xác định AdapterBoard context/delegate ownership | P1 | Proposed | M | Wrapped board behavior rõ | `ARCH-009` |
| `FIX-010` Giữ class plugin đủ lifetime hoặc giới hạn plugin thành value type | P1 | Done | M | Lazy construction không BAD ACCESS | Commit `f428427`; class-plugin lifetime regression |
| `FIX-011` Sửa URL opener result contract | P1 | Proposed | M | Return đúng plugin thực sự selected/handled | `COR-010` |

Task 8 chỉ làm rõ contract 1.x hiện tại: giá trị synchronous trả về toàn bộ matched candidates trước selection, không phải các plugin thực sự được chọn/xử lý. `FIX-011` vẫn ở trạng thái `Proposed` và được defer cho một async/additive result API được thiết kế riêng.

### 12.5. Concurrency

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `CONC-001` Viết concurrency ADR | P0 | Deferred | M | Isolation/executor contract rõ | ADR-0001 proposal đã deferred khỏi 1.61; follow-up plan cần consumer evidence |
| `CONC-002` Chọn và triển khai isolation model cho orchestration/UIKit | P0 | Deferred | L | Swift 6-safe ownership model | MainActor chỉ là một option trong follow-up riêng |
| `CONC-003` Loại bỏ hoặc cô lập global caches | P0 | In progress | L | Không data race | Targeted caches đã lock trong Tasks 2–3; broader isolation deferred |
| `CONC-004` Audit compound operations trong safe collections | P0 | Done | M/L | Check-then-act atomic | Commits `dadf9a5`/`dc461ba`; reentrant factory regression green |
| `CONC-005` Sendable audit cho IDs/options/routes/closures | P0 | Deferred | L | Swift 6 compile | Follow-up; không thêm public constraint trong 1.61 |
| `CONC-006` Document callback executor và hop policy | P1 | In progress | M | Consumer không đoán queue | 1.61 documents unchanged caller-controlled behavior; future hop policy deferred |
| `CONC-007` Thêm Thread Sanitizer/stress CI job định kỳ | P1 | Proposed | M | Detect race regression | Sau core fixes |

### 12.6. Lifecycle và ownership

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `LIFE-001` Lifecycle state machine RFC | P0 | Proposed | L | State/transition contract rõ | `ARCH-003` |
| `LIFE-002` ActivationID và idempotent completion | P0 | Proposed | L/XL | Không stale/double completion | Sau `LIFE-001` |
| `LIFE-003` Subscription/cable lifetime API | P1 | Proposed | L | Repeated activation không tích lũy handler | `COR-006`, `COR-007` |
| `LIFE-004` Audit/remove controller lookup từ Board | P1 | Proposed | L | Enforce stateless boundary | `ARCH-004` |
| `LIFE-005` Refactor Attachable storage thành scoped ownership | P1 | Proposed | L | Không global table/test contamination | `ARCH-010`, `CON-003` |
| `LIFE-006` Thêm deallocation probes và lifetime assertions | P1 | Proposed | M | Lifecycle có test evidence | `QA-004` |

### 12.7. API và Boardy 2

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `API-001` Inventory và phân loại toàn bộ public API | P1 | Selected | L | Biết supported/SPI/deprecated surface | `ARCH-006` |
| `API-002` Typed route RFC và prototype | P1 | Proposed | XL | End-to-end type safety | `ARCH-001`, `D-007` |
| `API-003` Thiết kế 1.x compatibility bridge | P1 | Proposed | L/XL | Migration theo từng module | Sau `API-002` |
| `API-004` Tách Foundation core khỏi UIKit | P1 | Proposed | XL | Headless-testable core | `ARCH-005`, `D-006` |
| `API-005` Structured diagnostics API | P1 | Proposed | L | Observable, testable failures | `ARCH-007` |
| `API-006` Async/await và cancellation contract | P1 | Proposed | XL | Modern execution API | `FIX-005`, `CONC-001` |
| `API-007` Deprecation and project-version policy | P0 | Done | M | Breaking changes predictable | Owner approved iOS 14 minor policy and legacy executor contract; final API inventory remains `API-001` |

### 12.8. Tests và quality engineering

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `TEST-001` Thay real-time waits bằng controllable executor/fake clock | P1 | Proposed | L | Deterministic fast tests | `QA-002` |
| `TEST-002` Negative tests cho mismatch và Release behavior | P0 | Proposed | M | Không silent message loss | `ARCH-001` |
| `TEST-003` Reentrancy tests cho flow/combined flow | P0 | Done | M | Protect `FIX-002`/`FIX-003` | CombinedFlow reentrancy 3/3; dictionary reentrancy 3/3 corrective set |
| `TEST-004` Double completion/repeated activation tests | P0 | Proposed | M/L | Protect lifecycle contract | `ARCH-003` |
| `TEST-005` Cancellation/exactly-once tests cho task boards | P0 | Done | L | Protect `FIX-004`/`FIX-005` | BlockTask 12/12 passed five consecutive runs |
| `TEST-006` Memory release tests | P1 | Proposed | M/L | Verify board/controller/bus deallocation | `QA-004` |
| `TEST-007` Performance benchmark suite | P2 | Proposed | M/L | Activation/dispatch/memory baseline | `QA-005` |
| `TEST-008` Architecture tests cho package dependency direction | P1 | Proposed | M | Ngăn UIKit quay lại core | Sau `API-004` |

### 12.9. Documentation và samples

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `DOCS-001` Viết canonical architecture/terminology page | P0 | Selected | M | Một mental model chính thức | `DOC-001`, `D-002` |
| `DOCS-002` Rewrite README thành install + quick start + support matrix | P0 | Selected | M | First-use path chính xác | `DOC-002` |
| `DOCS-003` Archive/label legacy guides | P1 | Selected | S/M | Không copy pattern cũ | `DOC-001`, `DOC-007` |
| `DOCS-004` Sửa example modules thành reference implementation | P1 | Proposed | L | Sample tuân thủ stateless/lifecycle rules | `DOC-003`, `COR-006`, `COR-007` |
| `DOCS-005` DocC API reference và tutorials | P1 | Proposed | L | Versioned discoverable docs | `DOC-004` |
| `DOCS-006` Migration guides theo release | P0 | Selected | M mỗi source/API hoặc platform-floor change | Consumer biết cách nâng version | `REL-004` |
| `DOCS-007` Troubleshooting và diagnostics guide | P1 | Proposed | M | Giảm support load | Sau `API-005` |
| `DOCS-008` Đồng bộ AGENTS/build instructions với thực tế | P0 | Selected | S | Canonical commands chạy được | `DOC-005`, `BUILD-003` |

### 12.10. Release, security và open source

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `OSS-001` Thêm CHANGELOG và release-note template | P0 | Done | S/M | Release history audit được | Task 12 baseline; release entry remains candidate until final gate |
| `OSS-002` Thêm CONTRIBUTING/CODE_OF_CONDUCT/SUPPORT | P1 | Done | M | Contributor operating model | Task 12 baseline |
| `OSS-003` Thêm SECURITY.md và private reporting path | P0 | Done | S | Security response contract | Private contact `congnc.if@gmail.com`; GitHub PVR not advertised while disabled |
| `OSS-004` Issue/PR templates, CODEOWNERS và labels | P1 | In progress | M | Maintainer workflow rõ | Forms/PR template and sole-owner CODEOWNERS done; label policy deferred |
| `OSS-005` Automated GitHub release từ signed semantic tag | P0 | Proposed | M/L | Pod/SPM/tag/release đồng bộ | `REL-004` |
| `OSS-006` SBOM, provenance và dependency review | P1 | Proposed | M/L | Supply-chain baseline | `REL-009` |
| `OSS-007` Pin template repos và dependency versions | P0 | In progress | M | Reproducible inputs | Template revisions verified end-to-end under `.build-local/tmp`; package dependency pin remains Task 10 |
| `OSS-008` Remove/quarantine dangerous local utility scripts | P1 | Done | S | Safer contributor defaults | `claude-dangerous.sh` removed |
| `OSS-009` Sửa podspec metadata/homepage | P2 | Selected | S | Public metadata đúng | `REL-012` |
| `OSS-010` CocoaPods-to-SPM transition communication | P0 | Selected | M | Consumer có đường chuyển trước trunk deadline | `REL-011` |

### 12.11. Organizational adoption

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `ADOPT-001` Chọn 2–3 pilot modules có độ phức tạp khác nhau | P1 | Proposed | M | Evidence ngoài sample | Sau G1 |
| `ADOPT-002` Định nghĩa adoption rubric và exception process | P1 | Proposed | M | Không ép dùng Boardy sai use case | `D-012` |
| `ADOPT-003` Tạo golden-path module template | P1 | Proposed | L | Onboarding nhất quán | Sau docs/API stabilization |
| `ADOPT-004` Đo onboarding time và migration cost | P1 | Proposed | M | Adoption dựa trên dữ liệu | Trong pilots |
| `ADOPT-005` Thiết lập maintainer office hours/support SLA | P2 | Proposed | Ongoing | Consumer có support channel | Sau `FOUND-001` |
| `ADOPT-006` Thu thập production telemetry opt-in | P2 | Proposed | L | Reliability/performance evidence | Cần privacy decision |
| `ADOPT-007` Maturity review sau mỗi pilot release cycle | P1 | Proposed | M | Quyết định Recommended dựa trên gate | G2/G3 |

---

## 13. Quality gates

### G0 — Review-ready

- Living document được review.
- Strategic option được chọn.
- Technical/release owner được chỉ định; deferred backup continuity risk được chấp nhận và ghi rõ.
- Consumer inventory hoàn tất.
- Support matrix được quyết định.

### G1 — Build-trusted

- Framework và test suite build/run xanh trên supported Xcode matrix.
- Hosted CI chạy xanh trên exact final commit SHA cho toàn supported matrix; required checks được cấu hình và không thể bị bỏ qua bởi local-only evidence.
- Không còn test compile failure.
- Các correctness finding P0 có regression tests.
- SwiftPM clean-consumer smoke test xanh.
- CocoaPods lint xanh trong transition period.
- Changelog, SECURITY.md và release process tồn tại.
- Candidate build/test xanh trong language mode được support; Swift 6 language-mode warning gate chỉ
  áp dụng sau khi follow-up isolation plan được duyệt.

### G2 — Pilot-ready

- Concurrency ADR được triển khai.
- Lifecycle và callback executor semantics được document.
- Double completion, reentrancy, cancellation và deallocation tests xanh.
- Public API baseline được lưu.
- Canonical docs và reference sample không mâu thuẫn.
- Ít nhất một pilot module hoàn tất integration.

### G3 — Organization-recommended

- Ít nhất hai pilot qua một release cycle mà không có P0 framework incident.
- Onboarding và migration metrics đạt target đã quyết định.
- Có owner, SLA và exception process.
- API compatibility và release automation được enforce.
- Performance/memory benchmark không regression vượt budget.
- Security và supply-chain checks xanh.

### G4 — Public-stable

- Semantic version/deprecation policy được tuân thủ qua ít nhất hai releases.
- DocC, migration guides và public roadmap đầy đủ.
- Signed release, SBOM và provenance được publish.
- Contributor workflow đã được thử qua external hoặc cross-team contribution.
- Maintainer bus factor tối thiểu là hai người có release access.

---

## 14. Verification strategy

| Layer | Required verification |
|---|---|
| Contract types | Compile-time API tests, API digester, Sendable checks |
| Lifecycle | State-transition, double completion, stale callback, repeated activation tests |
| Flow engine | Order, matching, reentrancy, nil output, batch/latest strategy tests |
| Task engine | Exactly-once, cancellation, queue/latest/only/concurrent semantics |
| Plugin system | Lazy construction, class/value plugin lifetime, duplicate registration, reset/test isolation |
| UI adapters | Current UIKit caller responsibility, missing context behavior, iPad action sheet test; actor enforcement deferred |
| Memory | Weak target release, controller/board deallocation, global storage cleanup |
| Concurrency | 1.61 lock/executor characterization; Swift 6 compile, TSan và actor-boundary tests deferred |
| Distribution | Clean SwiftPM consumer, CocoaPods lint, package product import tests |
| Release | Tag/version/changelog consistency, SBOM/provenance validation |

### 14.1. Test design rules candidate

- Không dùng arbitrary sleep để chứng minh correctness.
- Async test phải kiểm soát scheduler/clock khi có thể.
- Mỗi P0 defect phải có regression test trước hoặc cùng fix.
- Tests phải chạy được cả Debug và một Release-compatible configuration cho mismatch behavior.
- Memory tests phải có bounded retry thay vì timing assumption cố định.
- Integration tests không thay thế unit tests cho lifecycle state machine.

---

## 15. Success metrics candidate

Targets cụ thể cần được quyết định sau consumer baseline. Dưới đây là nhóm metric cần đo.

### 15.1. Engineering health

- CI pass rate.
- Flaky-test rate.
- Build/test duration.
- Boardy-owned warnings theo toolchain.
- API breaking changes phát hiện trước release.
- Open P0/P1 defects và mean time to resolution.

### 15.2. Runtime quality

- Activation dispatch latency.
- Flow dispatch latency.
- Board/controller lifetime leak count.
- Duplicate completion/observer incidents.
- Crash-free sessions liên quan Boardy.
- Task cancellation correctness incidents.

### 15.3. Developer experience

- Thời gian từ clean app đến first working Board.
- Thời gian tạo và integrate một module mới.
- Số bước/manual edits ngoài template.
- Tỷ lệ support requests trên mỗi adopting team.
- Documentation task success rate.

### 15.4. Adoption và sustainability

- Số production modules/apps sử dụng supported version.
- Tỷ lệ consumer cập nhật trong release window.
- Số maintainers có thể review/release độc lập.
- Issue/PR response time.
- Release cadence và deprecation compliance.

---

## 16. Risk register

| Risk | Likelihood | Impact | Mitigation candidate | Status |
|---|---|---|---|---|
| Rewrite scope vượt capacity | Medium | High | Chọn staged strategy, gate theo phase | Open |
| Swift 6 migration phá callback/API behavior | High | High | Tách khỏi 1.61; follow-up isolation RFC + consumer compatibility tests | Deferred from current release |
| Type-safe v2 tạo hai ecosystem lâu dài | Medium | High | Time-box bridge và deprecation policy | Open |
| Consumer 1.x không được inventory | High | High | `FOUND-002` trước breaking decision | Open |
| CocoaPods trunk đóng trước khi SPM adoption hoàn tất | High | High | Ưu tiên `BUILD-003`, `OSS-010` | Open |
| Maintainer duy nhất trở thành bottleneck | High | High | Documented single-owner release process now; add/test backup continuity later | Accepted for 1.61; follow-up open |
| Test stabilization kéo dài do real-time assumptions | Medium | Medium | Fake clock/executor và incremental conversion | Open |
| Public API quá rộng ngăn refactor | High | High | API inventory, SPI/internalization, major-version policy | Open |
| Samples tiếp tục truyền pattern cũ | High | Medium | Reference sample gate trong docs CI | Open |
| Global state gây flaky tests và data races | High | High | Lock/transaction hiện tại; instance ownership hoặc approved isolation ở follow-up | Open |
| Optional Composable dependency làm chậm package split | Medium | Medium | Tách product optional, pin version | Open |
| Open-source launch trước khi support model sẵn sàng | Medium | High | Chỉ đạt Public-stable sau G4 | Open |

---

## 17. Open decisions

Không decision nào dưới đây được coi là đã chốt nếu chưa có entry tương ứng trong Decision Log.

| ID | Quyết định cần đưa ra | Options chính | Khuyến nghị audit | Trạng thái |
|---|---|---|---|---|
| `D-001` | Ai là technical/release owner? | Cá nhân, working group, platform team | Sole owner `congnc.if@gmail.com` / `@congncif`; backup later | Approved; backup continuity deferred and non-blocking |
| `D-002` | Product positioning chính là gì? | Mobile microservices, orchestration framework, modular runtime | Legacy-compatible modular orchestration with typed façades | Approved for Option A |
| `D-003` | Chọn chiến lược evolution nào? | Option A, B, C | Option A hardening | Selected for execution: Option A/pre-G1 |
| `D-004` | Support matrix? | iOS/Xcode/Swift versions | Xcode 26.4.1 hiện có; local executable tests chỉ dùng iPhone 17/iOS 26.4; iOS floor 14+ | Approved for Option A; iOS 18.3, other-device rows và N-1 Xcode deferred với hosted CI |
| `D-005` | Concurrency isolation model? | MainActor-first, actor-per-motherboard, caller-controlled | Giữ caller-controlled trong 1.61; không thêm actor/precondition/hop; preserve toàn bộ `BlockTaskBoard` terminal executor/order | Approved for Option A; isolation redesign deferred to separate plan |
| `D-006` | SwiftPM product structure ban đầu? | Một umbrella target, nhiều products, staged split | Một umbrella product/module trong 1.x | Approved for Option A |
| `D-007` | Typed route contract? | Generic route, generated IO, macro/codegen | Generic route trước; macro chỉ khi có evidence | Open |
| `D-008` | Deprecation/version contract? | Một minor, một major, time-based | Project policy: platform-floor change có thể ở minor; major dành cho big update | Approved: 1.61.0 for iOS 14 floor |
| `D-009` | Task cancellation semantics? | Best effort, cooperative, guaranteed terminal callback | Cooperative + exactly-one terminal callback | Approved for Option A |
| `D-010` | Missing context policy? | Precondition, optional/result, injected presenter | Typed failure cho public APIs; precondition chỉ invariant nội bộ | Open |
| `D-011` | Architecture governance? | ADR, RFC, maintainer vote | ADR cho local decision, RFC cho public API | Approved for Option A |
| `D-012` | Khi nào Boardy không nên được dùng? | Không có exception, team discretion, adoption rubric | Adoption rubric + exception process | Open |
| `D-013` | Có tiếp tục hỗ trợ Composable/Attachable? | Core, optional, deprecate | Giữ trong Boardy umbrella; SwiftPM dùng UIComposableCore | Approved for Option A |
| `D-014` | Public launch timing? | Ngay sau G1, sau G3, sau G4 | Marketing launch sau G4; repo vẫn public trong quá trình hardening | Open |

### 17.1. Gate A1 status

**Approved ngày 2026-07-14.** Requester chọn `congnc.if@gmail.com` / `@congncif` làm owner và
release actor duy nhất, defer backup continuity, approve `docs/API_STABILITY_1X.md`, iOS 14/minor
1.61.0 matrix và release-level consumer disposition. GitHub-only release là opt-in và không publish
CocoaPods; mọi consumer dưới iOS 14 giữ version hiện tại cho đến khi migrate, pin `< 1.61` hoặc
retire. ADR-0001 giữ `Deferred`; `D-005` giữ caller-controlled/no-isolation-change. Task 9 được phép
bắt đầu.

---

## 18. Decision log

| Date | Decision | Rationale | Consequences | Owner |
|---|---|---|---|---|
| 2026-07-14 | Tạo một living document tổng hợp trước khi chọn work item | Cần baseline chung để review và quyết định theo từng phần | Tất cả backlog giữ trạng thái `Proposed`; chưa authorize implementation | Requester + audit author |
| 2026-07-14 | Chọn Option A làm hướng lập implementation plan | Ưu tiên khôi phục trust cho Boardy 1.x với migration cost thấp trước khi cân nhắc typed core | Draft plan tập trung pre-G1 technical candidate; runtime `Any?` và v2 work được giữ ngoài scope; chưa authorize implementation | Requester |
| 2026-07-14 | Tách hosted CI khỏi plan Option A hiện tại | Hạ tầng CI chưa sẵn sàng | `BUILD-002`, final-SHA hosted matrix và required checks giữ `Proposed` cho plan sau; plan hiện tại không được claim G1 | Requester |
| 2026-07-14 | Nâng Boardy deployment floor lên iOS 14+ | Requester chọn bỏ hỗ trợ iOS 12/13 để mở đường cho Swift concurrency runtime | Consumer inventory phải ghi migration impact; implementation vẫn chưa được authorize | Requester |
| 2026-07-14 | Giữ release ở minor `1.61.0` | Project dành major cho một big update thay vì chỉ thay đổi minimum iOS | Versioning policy này không được mô tả là strict SemVer; iOS 12/13 drop phải nổi bật trong compatibility matrix, migration guide và release notes | Requester |
| 2026-07-14 | Approve Option A decision package | Bắt đầu hardening 1.x mà không mở typed-core/major scope | Approve `D-002`, `D-003`, `D-004`, `D-006`, `D-008`, `D-009`, `D-011`, `D-013`; `D-005` giữ provisional đến Gate A1 owner approval | Requester + integrator |
| 2026-07-14 | Thực thi trực tiếp trên branch, không dùng worktree | Requester chọn workflow đơn giản cho hai repository | Dùng `codex/boardy-1.61.0` và `codex/uicomposable-1.1.0`; commit/push/tag/GitHub Release được authorize sau khi gates xanh | Requester |
| 2026-07-14 | Git/GitHub-only release và dùng Xcode hiện có | CocoaPods chưa cần publish; máy chỉ có Xcode 26.4.1 | Podspec vẫn được lint/chuẩn bị nhưng không push trunk; local executable tests chỉ dùng iPhone 17/iOS 26.4; iOS 18.3, other-device rows và N-1 Xcode deferred cùng hosted CI | Requester |
| 2026-07-14 | Giữ project-scoped build/cache dưới repo external drive | Tránh ghi DerivedData/temp/package checkout vào ổ hệ thống và tránh xin quyền ngoài workspace | Dùng ignored `.build-local/`; Xcode 26.4.1 dùng repo-local DerivedData/SourcePackages và `-disablePackageRepositoryCache`, không dùng empty custom `-packageCachePath`; CoreSimulator system state không di chuyển | Requester + integrator |
| 2026-07-14 | Chốt checkpoint Tasks 0–8 trước Gate A1 | Correctness fixes độc lập với concurrency-boundary decision của Task 9 | Immutable API baseline + bảy semantic commits; corrective review regressions 3/3 và full suite 59/59; Gate A1 vẫn blocked | Integrator |
| 2026-07-14 | Chỉ định owner/security và chọn nhánh executor 1.x | Cần continuity, private reporting và compatibility contract trước Task 9 | Technical owner `congnc.if@gmail.com` / `@congncif`; backup `congnc1@gmail.com` với handle/access pending; security contact `congnc.if@gmail.com`; preserve toàn bộ legacy `BlockTaskBoard` executor/order; full Gate A1 vẫn pending | Requester + integrator |
| 2026-07-14 | Chuyển MainActor/Swift 6 isolation khỏi 1.61.0 | MainActor tạo quá nhiều source/behavior concerns cho một minor release | 1.61 giữ caller-controlled execution, không thêm actor annotation/precondition/queue hop; Swift 6 language mode, Sendable và isolation chuyển sang follow-up riêng; Gate A1 chỉ còn platform/consumer/API policy | Requester |
| 2026-07-14 | Cho phép GitHub-only 1.61.0 release trước G1 | Requester đã authorize tag/GitHub Release và defer hosted CI | Sau local gates có thể publish annotated tag/GitHub Release với evidence boundary rõ; không claim G1, organization production support, signed release hoặc CocoaPods availability | Requester + integrator |
| 2026-07-14 | Dùng một owner và đóng Gate A1 | Backup procedure không được phép làm chậm vấn đề kỹ thuật chính | Sole owner/release actor `congnc.if@gmail.com` / `@congncif`; backup continuity deferred; consumer opt-in disposition, API policy và iOS 14 matrix approved; Task 9 unblocked | Requester |

Draft chi tiết để review: [Boardy Option A — 1.x Hardening Implementation Plan](superpowers/plans/2026-07-14-boardy-option-a-1x-hardening.md).

---

## 19. Review and selection workflow

Quy trình review đề xuất:

1. Review Executive Assessment và Vision trước.
2. Xác nhận hoặc sửa maturity scorecard.
3. Review P0 findings; đánh dấu finding nào cần thêm evidence.
4. Trả lời `D-001` đến `D-006` để xác lập governance và technical baseline.
5. Chọn strategic Option A/B/C.
6. Có thể tạo implementation-plan draft để hỗ trợ review; draft không tự chuyển work item và không authorize execution.
7. Khi requester phê duyệt execution, chuyển đầy đủ decision/work item liên quan từ `Proposed` sang `Selected` và ghi rationale/consequences/owner trong Decision Log.
8. Sau mỗi phase, cập nhật gates, metrics, risks và Decision Log trong tài liệu này; không mark G1 khi `BUILD-002` chưa hoàn tất.

### Candidate first selection nếu chọn Option B

Nhóm đầu tiên có dependency thấp và khôi phục trust nhanh nhất:

- `FOUND-001` đến `FOUND-004`
- `BUILD-001` đến `BUILD-006`
- `FIX-001` đến `FIX-007`
- `CONC-001`
- `TEST-002` đến `TEST-005`
- `DOCS-001`, `DOCS-002`, `DOCS-008`
- `OSS-001`, `OSS-003`, `OSS-005`, `OSS-007`, `OSS-010`

Danh sách này là recommendation, không phải selection.

---

## 20. Evidence index

### 20.1. Vision và documentation

- [README — Why Boardy](../README.md#why-boardy)
- [README — stateless Board guidance](../README.md#core-concepts)
- [Boardy Modularization](Boardy%20Modularization.md)
- [Usage Guide tiếng Việt](UsageGuide-vi.md)
- [Activation Barrier](Activation%20Barrier.md)
- [ComponentKit](ComponentKit.md)
- [ServiceMap](ServiceMap.md)
- [Open an URL](Open%20an%20URL.md)

### 20.2. Core architecture

- [`BoardType.swift`](../Boardy/Core/BoardType/BoardType.swift)
- [`Motherboard.swift`](../Boardy/Core/Board/Motherboard.swift)
- [`IOInterface.swift`](../Boardy/Core/BoardType/IOInterface.swift)
- [`BoardInputModel.swift`](../Boardy/Core/BoardType/BoardInputModel.swift)
- [`Flow.swift`](../Boardy/Core/BoardType/Flow.swift)
- [`CombinedFlow.swift`](../Boardy/Core/BoardType/CombinedFlow.swift)
- [`Bus.swift`](../Boardy/Core/Board/Bus.swift)

### 20.3. Plugins, tasks và lifecycle

- [`PluginLauncher.swift`](../Boardy/ModulePlugin/PluginLauncher.swift)
- [`ModulePlugin.swift`](../Boardy/ModulePlugin/ModulePlugin.swift)
- [`Attachable.swift`](../Boardy/Attachable/Attachable.swift)
- [`BlockTaskBoard.swift`](../Boardy/ComponentKit/BlockTaskBoard.swift)
- [`AdapterBoard.swift`](../Boardy/ComponentKit/AdapterBoard.swift)
- [`AlertBoard.swift`](../Boardy/ComponentKit/AlertBoard.swift)

### 20.4. Build, release và supply chain

- [`Boardy.podspec`](../Boardy.podspec)
- [`.travis.yml`](../.travis.yml)
- [`tools/install-template.sh`](../tools/install-template.sh)
- [`tools/init-module.sh`](../tools/init-module.sh)
- [CocoaPods Boardy](https://cocoapods.org/pods/Boardy)
- [CocoaPods trunk read-only plan](https://blog.cocoapods.org/CocoaPods-Specs-Repo/)
- [Swift Package Manager documentation](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/)
- [Publishing a Swift package](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/releasingpublishingapackage/)
- [Swift package security](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/packagesecurity/)
- [GitHub dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependency-review)
- [GitHub repository security quickstart](https://docs.github.com/en/code-security/getting-started/quickstart-for-securing-your-repository)

### 20.5. Option A execution checkpoint

- [API stability policy](API_STABILITY_1X.md)
- [API baseline provenance](api/BASELINE_PROVENANCE.md)
- [Concurrency ADR](adr/0001-boardy-1x-main-actor.md)
- [Consumer inventory](governance/CONSUMER_INVENTORY.md)
- [Ownership blockers](governance/OWNERSHIP.md)
- [Option A implementation plan](superpowers/plans/2026-07-14-boardy-option-a-1x-hardening.md)

| Scope | Commit |
|---|---|
| Immutable API baseline | `53664db10ae92924a6a7ca97bf0d0b906d0a3cca` |
| Test baseline + attachment locking | `dadf9a5aee4783d33d39f21ee5eeef45d49ac1db` |
| Atomic collection/barrier lifecycle | `dc461ba19fbaa06186791f614bc1a1ad377121ec` |
| Generic activation lifecycle | `a00b840c5538186e281231ede83ef1b1425a8beb` |
| CombinedFlow nil/reentrancy | `dd78e106b1d8db0e2f1c786e7c239f4d8647ba55` |
| BlockTask exactly-once/cancellation | `b755a0f2978f43d448cce0521d2d50594bbaec51` |
| Action-sheet popover safety | `d9cd462272f2f2710f48f70a1cb6863103cf0020` |
| Plugin lifetime/API compatibility | `f4284278c348f279c833c32e231d39473e5dd5f1` |
| UIComposable Core package prerequisite | `ee04384063fcd0ebdd3d3b4e12a15d62cd0f3b94` in sibling repository |

---

## 21. Audit verification record

### 21.1. Pre-execution audit baseline

Các hoạt động dưới đây mô tả trạng thái tại audit baseline, trước khi Option A sửa source:

| Activity | Result |
|---|---|
| Inventory source/docs/tests/manifests | Completed |
| Read toàn bộ framework source | Completed |
| Read current examples và tests | Completed |
| CodeGraph structural context | Completed |
| CodeGraph impact của central message path | Wide impact; migration phải staged |
| Xcode framework build | Passed trong Swift 5 compatibility mode |
| Xcode strict-concurrency build | Passed với Boardy-owned warnings cần xử lý |
| Xcode test | Failed at compile due stale `StaticStorage` reference |
| Public GitHub/CocoaPods/release review | Completed ngày 2026-07-14 |
| Source modifications trong audit | None |

### 21.2. Option A Tasks 0–8 execution checkpoint

| Activity | Result |
|---|---|
| API baseline capture/provenance | PASS; immutable commit `53664db` |
| UIComposable Core package prerequisite | Swift 5 + Swift 6 strict tests and pod lint passed at `ee043840` |
| Boardy semantic commits | Tasks 2–8 committed through `f428427` |
| Review RED | 3 tests, 5 failures — expected reproduction of reentrant factory and partial/mismatched barrier installation defects |
| Review GREEN | 3/3 passed after corrective batch |
| Final checkpoint full test | 59/59 passed, zero failures, iPhone 17 only |
| Xcode project-scoped data | `.build-local/` ignored; DerivedData, SourcePackages, temp and results stored on external workspace |
| Hosted CI / older runtime-device matrix | Deferred; not claimed |
| Gate A1 / Task 9 | Gate approved with sole owner and opt-in consumer disposition; Task 9 authorized; MainActor removed from scope |

### 21.3. Task 12 governance/tooling checkpoint

| Activity | Result |
|---|---|
| Governance/community files | CHANGELOG, contributing, conduct, support, security and releasing baselines created |
| GitHub intake | Bug/feature forms and PR template parse successfully; CODEOWNERS designates sole confirmed owner `@congncif` |
| Template installer | Pinned revision `892828b9c003d1194fb044921000708345e00493`; runtime verification passed with repo-local synthetic HOME |
| Module generator | Pinned revision `62e618beba9900a26970deb722f12163c77c319f`; sample module generated in repo-local disposable directory |
| Duplicate mutable path | `Example/init-module.sh` delegates to the canonical pinned generator |
| Unsafe helper | `claude-dangerous.sh` removed |
| Project-scoped side effects | Confined to ignored `.build-local/`; cleanup traps left no checkout work directories |

---

## 22. Change log

| Document version | Date | Change |
|---|---|---|
| 0.18.0 | 2026-07-14 | Theo quyết định requester, chuyển sang sole owner/release actor `congnc.if@gmail.com` / `@congncif`, defer backup continuity; approve opt-in consumer disposition, API policy và iOS 14/minor matrix; đóng Gate A1 và tạo single-owner CODEOWNERS |
| 0.17.0 | 2026-07-14 | Phân tách GitHub release khỏi G1: local gates có thể publish annotated 1.61.0 theo authority đã cấp; hosted CI tiếp tục block organization production-support claim; signed release và CocoaPods publish vẫn deferred |
| 0.16.0 | 2026-07-14 | Theo quyết định requester, remove toàn bộ MainActor/Swift 6 isolation khỏi Option A 1.61.0; approve caller-controlled/no-precondition/no-hop `D-005`; defer `CONC-001`/`CONC-002`/`CONC-005` và strict-language-mode verification sang follow-up; Gate A1 chỉ còn backup access, consumer disposition và API/platform approval |
| 0.15.0 | 2026-07-14 | Ghi nhận technical/backup/security contacts, verify technical handle `@congncif`, giữ backup handle/access pending; approve nhánh preserve toàn bộ legacy `BlockTaskBoard` executor/order; thêm Task 12 governance/community baseline, pinned tooling runtime evidence và xóa unsafe helper; Gate A1 còn consumer dispositions và full API/ADR/support-matrix approval |
| 0.14.0 | 2026-07-14 | Ghi nhận immutable API baseline và semantic commits Tasks 2–8; checkpoint review RED 3/5 → GREEN 3/3, full suite 59/59; chuẩn hóa Xcode data dưới `.build-local/` với `-disablePackageRepositoryCache`; giữ Gate A1 blocked và Task 9 chưa bắt đầu |
| 0.13.0 | 2026-07-14 | Chuyển toàn bộ project-scoped temporary/build cache vào `.build-local/` ngay trong repo trên external drive; thêm Git/Claude ignore và đổi API tools sang local temp root mặc định |
| 0.12.0 | 2026-07-14 | Làm rõ Task 8 chỉ document URL matched-candidate semantics và giữ `FIX-011` Proposed/deferred; giới hạn local executable tests ở iPhone 17/iOS 26.4, defer iOS 18.3, other-device rows và N-1 Xcode |
| 0.11.0 | 2026-07-14 | Chuyển Option A sang execution: branch trực tiếp không worktree, Git/GitHub-only release, chưa publish CocoaPods; support matrix dùng Xcode 26.4.1 với simulator iOS 18.3/26.4 và defer N-1 Xcode |
| 0.10.0 | 2026-07-14 | Làm rõ MainActor-first không che nhánh Gate-A1 preserve toàn bộ BlockTask terminal ordering/Board messages; đồng bộ Option A plan 0.18.0 với reasoned cancellation tombstones và barrier dead-owner recovery |
| 0.9.0 | 2026-07-14 | Đồng bộ link review với Option A plan 0.17.0: final API evidence sau dependency lock, UIComposable tag gắn reviewed SHA, barrier owner/handoff và cancellation race trở thành execution/DoD gates; không thay đổi authorization hoặc hosted-CI scope |
| 0.8.0 | 2026-07-14 | Giới hạn Gate A1 ở MainActor hop hoặc preserve/defer legacy callback; additive executor API phải có RFC và plan amendment riêng |
| 0.7.0 | 2026-07-14 | Đồng bộ concurrency recommendation 1.x với Gate A1: MainActor-first internals, không thêm public Sendable constraint vào legacy generic và callback executor phụ thuộc consumer evidence |
| 0.6.0 | 2026-07-14 | Làm rõ compatibility strategy: source/API break dành cho major; minimum-platform change có thể ở minor theo project policy nhưng phải có inventory và migration disclosure |
| 0.5.0 | 2026-07-14 | Theo quyết định requester, giữ minor 1.61.0 cho iOS 14 floor và dành major cho big updates; ghi rõ đây là project versioning policy, không phải strict SemVer |
| 0.4.0 | 2026-07-14 | Ghi nhận đề xuất ban đầu iOS 14+ bằng semantic-major 2.0.0; quyết định version này đã bị thay thế bởi minor `1.61.0` ở revision 0.5.0, còn typed-core vẫn ngoài scope và hosted final-SHA check vẫn thuộc G1 |
| 0.3.0 | 2026-07-14 | Theo quyết định requester, tách hosted CI/`BUILD-002` sang plan sau, đổi Option A draft thành pre-G1 target và làm rõ draft-plan không đồng nghĩa selection/execution |
| 0.2.0 | 2026-07-14 | Ghi nhận Option A được chọn cho planning, liên kết implementation-plan draft và thêm UIComposable package-feasibility evidence; chưa chọn implementation work item |
| 0.1.0 | 2026-07-14 | Tạo baseline living assessment, finding register, candidate architecture, roadmap, backlog, gates, risks và decisions |
