//
//  ListViewController.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 12/12/19.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import UIKit

extension UIBoardItem: IdentifiableType {
    public var identity: String {
        return identifier
    }
}

open class ListViewController: UIViewController, UIBoardInterface {
    private typealias Section = AnimatableSectionModel<Int, UIBoardItem>
    private typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>

    public private(set) lazy var tableView: UITableView = UITableView()

    private let boardItemsRelay = BehaviorRelay<[UIBoardItem]>(value: [])

    public var boardItems: Binder<[UIBoardItem]> {
        return Binder(self) { target, value in
            target.boardItemsRelay.accept(value)
        }
    }

    private lazy var dataSource: DataSource = self.buildDataSource()
    private let displayItems = BehaviorRelay<[UIBoardItem]>(value: [])
    private var viewControllers: [UIViewController] = [] {
        didSet {
            for item in oldValue {
                if !viewControllers.contains(item) {
                    item.removeFromParent()
                }
            }
            for item in viewControllers {
                if !oldValue.contains(item) {
                    addChild(item)
                }
            }
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let disposeBag = DisposeBag()

    override open func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configurePresenter()
    }
}

extension ListViewController {
    private func configureView() {
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func buildDataSource() -> DataSource {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        let transition: DataSource.DecideViewTransition = { _, _, _ in .reload }

        return DataSource(
            animationConfiguration: animationConfiguration,
            decideViewTransition: transition,
            configureCell: { (_, tableView, _, model) -> UITableViewCell in
                let cellId = "ListViewCell"
                let cell: UITableViewCell
                if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellId) {
                    cell = dequeuedCell
                } else {
                    cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellId)
                }
                cell.selectionStyle = .none
                cell.contentView.backgroundColor = .clear
                cell.backgroundColor = .clear
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                if let subView = model.viewController?.view {
                    cell.contentView.addSubview(subView)
                    subView.snp.makeConstraints { maker in
                        maker.edges.equalToSuperview()
                    }
                }
                return cell
            }
        )
    }

    private func configurePresenter() {
        displayItems
            .map { [Section(model: 0, items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        boardItemsRelay
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let pages = $0.compactMap { $0.viewController }
                self.viewControllers = pages
                self.displayItems.accept($0)
            })
            .disposed(by: disposeBag)
    }
}
