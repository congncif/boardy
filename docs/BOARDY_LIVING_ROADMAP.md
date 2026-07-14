# Boardy — Living Assessment, Evolution & Open-Source Roadmap

> Tài liệu tổng hợp để review, lựa chọn và theo dõi từng bước nâng cấp Boardy.
>
> **Trạng thái quyết định:** chưa có hạng mục implementation nào được phê duyệt. Mọi work item trong tài liệu mặc định ở trạng thái `Proposed` cho đến khi được ghi nhận trong Decision Log.

| Thuộc tính | Giá trị |
|---|---|
| Trạng thái tài liệu | Draft for review |
| Phiên bản tài liệu | 0.1.0 |
| Ngày audit | 2026-07-14 |
| Cập nhật gần nhất | 2026-07-14 |
| Repository baseline | `master` tại commit `d62970a81432` |
| Framework release hiện tại | `1.60.1` |
| Owner tài liệu | Chưa chỉ định; được theo dõi bởi `D-001` |
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

### 4.3. Build verification ngày 2026-07-14

Môi trường kiểm chứng:

- Workspace: `Example/Boardy.xcworkspace`
- Framework scheme: `Boardy`
- Test scheme: `Boardy_Tests`
- Configuration: Debug
- Simulator: iPhone 17, iOS 26.4
- Derived data: `/tmp/BoardyDerivedData`

Kết quả:

| Check | Kết quả | Evidence |
|---|---|---|
| Framework build | Passed trong khoảng 18,2 giây | Build với `SWIFT_STRICT_CONCURRENCY=complete` |
| Strict concurrency | Warning | Nhiều warning trong source Boardy được compiler ghi nhận sẽ thành lỗi ở Swift 6 language mode |
| Test build/run | Failed trước khi chạy test | [`StaticStorage` không còn tồn tại](../Example/Tests/AttachableTests.swift#L25) |
| Warning volume | 45 warnings toàn project/dependencies trong lần build | Cần tách Boardy-owned warning khỏi dependency warning trong CI |

Kết luận: “framework build được” hiện chỉ đúng trong Swift 5 compatibility mode; chưa thể suy ra test suite hoặc Swift 6 readiness.

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
| Scalable execution | Thấp | Một số synchronized collections | Không có actor/MainActor contract, compound race, cancellation ambiguity |
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
| `CON-001` | P0 | Confirmed | UI orchestration không được cô lập bằng `@MainActor` | Swift 6 errors và UI access từ sai executor | Strict-concurrency build warnings trong AlertBoard, NoBoard và InstallableBoard |
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
| `REL-008` | P1 | Confirmed | `claude-dangerous.sh` chạy với skipped permissions | Không phù hợp để ship như project utility mặc định | [`claude-dangerous.sh`](../claude-dangerous.sh#L6) |
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

### 8.3. Concurrency: chọn một isolation model đơn giản

#### Khuyến nghị cho 1.x

- `Board`, `Motherboard`, flow registry, UI context và plugin composition: `@MainActor`.
- Background task executor: chạy ngoài MainActor, input/output phải `Sendable`.
- Completion quay về isolation domain đã document trước khi thay đổi lifecycle.
- Global cache chuyển thành actor hoặc instance-owned store.

Đây là lựa chọn ít migration cost nhất vì phần lớn Boardy orchestration liên quan UI và navigation.

#### Không khuyến nghị

- Đánh dấu hàng loạt `@unchecked Sendable` để làm hết warning mà không chứng minh invariants.
- Mỗi Motherboard là một actor độc lập ngay trong 1.x; cách này sẽ tạo nhiều `await` và reentrancy semantics mới.

#### Exit criteria

- Framework build trong Swift 6 language mode không có Boardy-owned concurrency warning.
- Public callback documentation nêu rõ actor/executor.
- Stress tests cho barrier, flow và task cancellation chạy dưới Thread Sanitizer.

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
- Breaking change chỉ phát hành trong major version.
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

**Phạm vi:** sửa correctness, Swift 6, CI, SPM, docs và release; giữ runtime `Any?`.

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
- Có technical owner và backup owner.
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
- Swift 6 concurrency baseline.
- Canonical README/compatibility matrix.
- Changelog, security và release automation.
- Pin external dependencies/template inputs.

**Exit criteria:** Quality Gate G1.

### Phase 2 — Lifecycle and concurrency hardening

**Mục tiêu:** framework có execution/lifecycle contract rõ và test được.

**Candidate duration:** 1–3 tháng.

**Phạm vi candidate:**

- `@MainActor` orchestration model.
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
| `FOUND-001` Chỉ định technical owner và backup | P0 | Proposed | S | Có quyền quyết định và continuity | `REL-010`, `D-001` |
| `FOUND-002` Inventory consumer/version đang dùng | P0 | Proposed | M | Biết migration blast radius | Trước API/deprecation decisions |
| `FOUND-003` Chọn strategic option A/B/C | P0 | Proposed | S | Scope program rõ | `D-003` |
| `FOUND-004` Chốt support matrix | P0 | Proposed | S | iOS/Swift/Xcode contract rõ | `DOC-002`, `D-004` |
| `FOUND-005` Thiết lập Decision Log/RFC workflow | P1 | Proposed | S | Các quyết định kiến trúc có history | `D-011` |

### 12.3. Build, CI và distribution

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `BUILD-001` Sửa test target compile | P0 | Proposed | S | Test suite có thể chạy | `QA-001` |
| `BUILD-002` Thêm GitHub Actions build/test matrix | P0 | Proposed | M | Required checks tin cậy | `REL-001`, `REL-002` |
| `BUILD-003` Thêm `Package.swift` và products ban đầu | P0 | Proposed | M/L | SwiftPM installation | `REL-003`, `D-006` |
| `BUILD-004` Thêm clean-consumer SPM smoke test | P0 | Proposed | M | Xác minh package dùng ngoài repo | Sau `BUILD-003` |
| `BUILD-005` Duy trì `pod lib lint` trong transition | P1 | Proposed | S | Không phá consumer CocoaPods hiện tại | `REL-011` |
| `BUILD-006` Đồng bộ Swift/platform metadata | P0 | Proposed | S | Một compatibility contract | `DOC-002`, `FOUND-004` |
| `BUILD-007` Thiết lập Swift API digester baseline | P1 | Proposed | M | Detect source/API break | `QA-006` |
| `BUILD-008` Tách Boardy warnings khỏi dependency warnings | P1 | Proposed | S/M | CI ownership rõ | `CON-001`–`CON-007` |
| `BUILD-009` Bật warnings-as-errors theo staged policy | P1 | Proposed | M | Ngăn warning debt quay lại | Sau `BUILD-008` |

### 12.4. Correctness và lifecycle fixes

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `FIX-001` Sửa early `return` trong `activateAllBoards` | P0 | Proposed | S | Tất cả board được xử lý | `COR-001` |
| `FIX-002` Refactor CombinedFlow không gọi handler trong lock | P0 | Proposed | M | Không reentrant deadlock | `COR-002` |
| `FIX-003` Thiết kế representation cho combined optional output | P0 | Proposed | M | `nil` là value hợp lệ | `COR-003` |
| `FIX-004` Guard BlockTask completion exactly-once | P0 | Proposed | M/L | Không double result/completion | `COR-004` |
| `FIX-005` Làm rõ BlockTask cancellation semantics | P1 | Proposed | L | Consistent cancellation/status | `COR-005`, `D-009` |
| `FIX-006` Thêm API `exempt` sạch và deprecate symbol zero-width | P1 | Proposed | S | API discoverable, migration an toàn | `COR-011` |
| `FIX-007` Cấu hình action-sheet popover hoặc require presentation anchor | P1 | Proposed | S | Không crash trên iPad | `COR-008` |
| `FIX-008` Thay synthetic context fallback bằng typed failure policy | P1 | Proposed | M | Không tiếp tục với UI object sai | `ARCH-008`, `D-010` |
| `FIX-009` Xác định AdapterBoard context/delegate ownership | P1 | Proposed | M | Wrapped board behavior rõ | `ARCH-009` |
| `FIX-010` Giữ class plugin đủ lifetime hoặc giới hạn plugin thành value type | P1 | Proposed | M | Lazy construction không BAD ACCESS | `COR-009` |
| `FIX-011` Sửa URL opener result contract | P1 | Proposed | M | Return đúng plugin thực sự selected/handled | `COR-010` |

### 12.5. Concurrency

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `CONC-001` Viết concurrency ADR | P0 | Proposed | M | Isolation/executor contract rõ | `D-005` |
| `CONC-002` MainActor-isolate orchestration và UIKit APIs | P0 | Proposed | L | UI/thread safety và Swift 6 readiness | Sau `CONC-001` |
| `CONC-003` Loại bỏ hoặc actor-isolate global caches | P0 | Proposed | L | Không data race | `CON-002`–`CON-004` |
| `CONC-004` Audit compound operations trong safe collections | P0 | Proposed | M/L | Check-then-act atomic | `CON-005` |
| `CONC-005` Sendable audit cho IDs/options/routes/closures | P0 | Proposed | L | Swift 6 compile | `CON-006`, `CON-007` |
| `CONC-006` Document callback executor và hop policy | P1 | Proposed | M | Consumer không đoán queue | `CON-008` |
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
| `API-001` Inventory và phân loại toàn bộ public API | P1 | Proposed | L | Biết supported/SPI/deprecated surface | `ARCH-006` |
| `API-002` Typed route RFC và prototype | P1 | Proposed | XL | End-to-end type safety | `ARCH-001`, `D-007` |
| `API-003` Thiết kế 1.x compatibility bridge | P1 | Proposed | L/XL | Migration theo từng module | Sau `API-002` |
| `API-004` Tách Foundation core khỏi UIKit | P1 | Proposed | XL | Headless-testable core | `ARCH-005`, `D-006` |
| `API-005` Structured diagnostics API | P1 | Proposed | L | Observable, testable failures | `ARCH-007` |
| `API-006` Async/await và cancellation contract | P1 | Proposed | XL | Modern execution API | `FIX-005`, `CONC-001` |
| `API-007` Deprecation and semantic-version policy | P0 | Proposed | M | Breaking changes predictable | `REL-004`, `D-008` |

### 12.8. Tests và quality engineering

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `TEST-001` Thay real-time waits bằng controllable executor/fake clock | P1 | Proposed | L | Deterministic fast tests | `QA-002` |
| `TEST-002` Negative tests cho mismatch và Release behavior | P0 | Proposed | M | Không silent message loss | `ARCH-001` |
| `TEST-003` Reentrancy tests cho flow/combined flow | P0 | Proposed | M | Protect `FIX-002`/`FIX-003` | `COR-002`, `COR-003` |
| `TEST-004` Double completion/repeated activation tests | P0 | Proposed | M/L | Protect lifecycle contract | `ARCH-003` |
| `TEST-005` Cancellation/exactly-once tests cho task boards | P0 | Proposed | L | Protect `FIX-004`/`FIX-005` | `COR-004`, `COR-005` |
| `TEST-006` Memory release tests | P1 | Proposed | M/L | Verify board/controller/bus deallocation | `QA-004` |
| `TEST-007` Performance benchmark suite | P2 | Proposed | M/L | Activation/dispatch/memory baseline | `QA-005` |
| `TEST-008` Architecture tests cho package dependency direction | P1 | Proposed | M | Ngăn UIKit quay lại core | Sau `API-004` |

### 12.9. Documentation và samples

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `DOCS-001` Viết canonical architecture/terminology page | P0 | Proposed | M | Một mental model chính thức | `DOC-001`, `D-002` |
| `DOCS-002` Rewrite README thành install + quick start + support matrix | P0 | Proposed | M | First-use path chính xác | `DOC-002` |
| `DOCS-003` Archive/label legacy guides | P1 | Proposed | S/M | Không copy pattern cũ | `DOC-001`, `DOC-007` |
| `DOCS-004` Sửa example modules thành reference implementation | P1 | Proposed | L | Sample tuân thủ stateless/lifecycle rules | `DOC-003`, `COR-006`, `COR-007` |
| `DOCS-005` DocC API reference và tutorials | P1 | Proposed | L | Versioned discoverable docs | `DOC-004` |
| `DOCS-006` Migration guides theo release | P0 | Proposed | M mỗi major change | Consumer biết cách nâng version | `REL-004` |
| `DOCS-007` Troubleshooting và diagnostics guide | P1 | Proposed | M | Giảm support load | Sau `API-005` |
| `DOCS-008` Đồng bộ AGENTS/build instructions với thực tế | P0 | Proposed | S | Canonical commands chạy được | `DOC-005`, `BUILD-003` |

### 12.10. Release, security và open source

| Work item | Priority | Status | Effort | Outcome | Finding/Dependency |
|---|---|---|---|---|---|
| `OSS-001` Thêm CHANGELOG và release-note template | P0 | Proposed | S/M | Release history audit được | `REL-004` |
| `OSS-002` Thêm CONTRIBUTING/CODE_OF_CONDUCT/SUPPORT | P1 | Proposed | M | Contributor operating model | `REL-005` |
| `OSS-003` Thêm SECURITY.md và private reporting path | P0 | Proposed | S | Security response contract | `REL-005` |
| `OSS-004` Issue/PR templates, CODEOWNERS và labels | P1 | Proposed | M | Maintainer workflow rõ | `REL-005`, `FOUND-001` |
| `OSS-005` Automated GitHub release từ signed semantic tag | P0 | Proposed | M/L | Pod/SPM/tag/release đồng bộ | `REL-004` |
| `OSS-006` SBOM, provenance và dependency review | P1 | Proposed | M/L | Supply-chain baseline | `REL-009` |
| `OSS-007` Pin template repos và dependency versions | P0 | Proposed | M | Reproducible inputs | `REL-006`, `REL-007` |
| `OSS-008` Remove/quarantine dangerous local utility scripts | P1 | Proposed | S | Safer contributor defaults | `REL-008` |
| `OSS-009` Sửa podspec metadata/homepage | P2 | Proposed | S | Public metadata đúng | `REL-012` |
| `OSS-010` CocoaPods-to-SPM transition communication | P0 | Proposed | M | Consumer có đường chuyển trước trunk deadline | `REL-011` |

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
- Technical owner và backup owner được chỉ định.
- Consumer inventory hoàn tất.
- Support matrix được quyết định.

### G1 — Build-trusted

- Framework và test suite build/run xanh trên supported Xcode matrix.
- Không còn test compile failure.
- Các correctness finding P0 có regression tests.
- SwiftPM clean-consumer smoke test xanh.
- CocoaPods lint xanh trong transition period.
- Changelog, SECURITY.md và release process tồn tại.
- Không có Boardy-owned warning bị định nghĩa là error trong Swift 6 mode.

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
| UI adapters | MainActor enforcement, missing context behavior, iPad action sheet test |
| Memory | Weak target release, controller/board deallocation, global storage cleanup |
| Concurrency | Swift 6 compile, Thread Sanitizer stress suite, actor-boundary tests |
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
| Swift 6 migration phá callback/API behavior | High | High | MainActor-first ADR, compatibility tests | Open |
| Type-safe v2 tạo hai ecosystem lâu dài | Medium | High | Time-box bridge và deprecation policy | Open |
| Consumer 1.x không được inventory | High | High | `FOUND-002` trước breaking decision | Open |
| CocoaPods trunk đóng trước khi SPM adoption hoàn tất | High | High | Ưu tiên `BUILD-003`, `OSS-010` | Open |
| Maintainer duy nhất trở thành bottleneck | High | High | Owner + backup + documented release process | Open |
| Test stabilization kéo dài do real-time assumptions | Medium | Medium | Fake clock/executor và incremental conversion | Open |
| Public API quá rộng ngăn refactor | High | High | API inventory, SPI/internalization, major-version policy | Open |
| Samples tiếp tục truyền pattern cũ | High | Medium | Reference sample gate trong docs CI | Open |
| Global state gây flaky tests và data races | High | High | Instance ownership/actor isolation | Open |
| Optional Composable dependency làm chậm package split | Medium | Medium | Tách product optional, pin version | Open |
| Open-source launch trước khi support model sẵn sàng | Medium | High | Chỉ đạt Public-stable sau G4 | Open |

---

## 17. Open decisions

Không decision nào dưới đây được coi là đã chốt nếu chưa có entry tương ứng trong Decision Log.

| ID | Quyết định cần đưa ra | Options chính | Khuyến nghị audit | Trạng thái |
|---|---|---|---|---|
| `D-001` | Ai là technical owner và backup owner? | Cá nhân, working group, platform team | Hai người có release access | Open |
| `D-002` | Product positioning chính là gì? | Mobile microservices, orchestration framework, modular runtime | Typed modular orchestration framework | Open |
| `D-003` | Chọn chiến lược evolution nào? | Option A, B, C | Option B | Open |
| `D-004` | Support matrix? | iOS/Xcode/Swift versions | Current và N-1 Xcode; iOS floor theo consumer inventory | Open |
| `D-005` | Concurrency isolation model? | MainActor-first, actor-per-motherboard, caller-controlled | MainActor-first cho 1.x | Open |
| `D-006` | SwiftPM product structure ban đầu? | Một umbrella target, nhiều products, staged split | Nhiều products nhưng có umbrella compatibility product | Open |
| `D-007` | Typed route contract? | Generic route, generated IO, macro/codegen | Generic route trước; macro chỉ khi có evidence | Open |
| `D-008` | Deprecation window? | Một minor, một major, time-based | Ít nhất một supported major migration window | Open |
| `D-009` | Task cancellation semantics? | Best effort, cooperative, guaranteed terminal callback | Cooperative + exactly-one terminal callback | Open |
| `D-010` | Missing context policy? | Precondition, optional/result, injected presenter | Typed failure cho public APIs; precondition chỉ invariant nội bộ | Open |
| `D-011` | Architecture governance? | ADR, RFC, maintainer vote | ADR cho local decision, RFC cho public API | Open |
| `D-012` | Khi nào Boardy không nên được dùng? | Không có exception, team discretion, adoption rubric | Adoption rubric + exception process | Open |
| `D-013` | Có tiếp tục hỗ trợ Composable/Attachable? | Core, optional, deprecate | Optional products; quyết định sau usage inventory | Open |
| `D-014` | Public launch timing? | Ngay sau G1, sau G3, sau G4 | Marketing launch sau G4; repo vẫn public trong quá trình hardening | Open |

---

## 18. Decision log

| Date | Decision | Rationale | Consequences | Owner |
|---|---|---|---|---|
| 2026-07-14 | Tạo một living document tổng hợp trước khi chọn work item | Cần baseline chung để review và quyết định theo từng phần | Tất cả backlog giữ trạng thái `Proposed`; chưa authorize implementation | Requester + audit author |

---

## 19. Review and selection workflow

Quy trình review đề xuất:

1. Review Executive Assessment và Vision trước.
2. Xác nhận hoặc sửa maturity scorecard.
3. Review P0 findings; đánh dấu finding nào cần thêm evidence.
4. Trả lời `D-001` đến `D-006` để xác lập governance và technical baseline.
5. Chọn strategic Option A/B/C.
6. Chuyển các work item đầu tiên từ `Proposed` sang `Selected`.
7. Chỉ sau đó mới tạo implementation plan chi tiết cho nhóm work item được chọn.
8. Sau mỗi phase, cập nhật gates, metrics, risks và Decision Log trong tài liệu này.

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

---

## 21. Audit verification record

Các hoạt động đã được thực hiện cho baseline này:

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

---

## 22. Change log

| Document version | Date | Change |
|---|---|---|
| 0.1.0 | 2026-07-14 | Tạo baseline living assessment, finding register, candidate architecture, roadmap, backlog, gates, risks và decisions |
