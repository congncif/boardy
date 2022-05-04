//
//  PlaceholderBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import RIBs

protocol PlaceholderDependency: Dependency {}

final class PlaceholderComponent: Component<PlaceholderDependency> {}

final class PlaceholderRootComponent: PlaceholderDependency {}

// MARK: - Builder

public protocol PlaceholderBuildable: Buildable {
    func build() -> PlaceholderRouting
}

final class PlaceholderBuilder: Builder<PlaceholderDependency>, PlaceholderBuildable {
    init() {
        super.init(dependency: PlaceholderRootComponent())
    }

    func build() -> PlaceholderRouting {
        let viewController = PlaceholderViewController()
        let interactor = PlaceholderInteractor(presenter: viewController)
        return PlaceholderRouter(interactor: interactor, viewController: viewController)
    }
}

public final class PlaceholderExBuilder: PlaceholderBuildable {
    public init() {}

    public func build() -> PlaceholderRouting {
        PlaceholderBuilder().build()
    }
}
