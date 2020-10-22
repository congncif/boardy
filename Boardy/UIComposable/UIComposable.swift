//
//  UIComposable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//

import Foundation
import UIKit

public struct UIElement: Equatable {
    public let identifier: String
    public var contentViewController: UIViewController?
    public var configuration: Any? // use for UI configuration

    private var version: Double

    public init(identifier: String, contentViewController: UIViewController?, configuration: Any? = nil) {
        self.identifier = identifier
        self.contentViewController = contentViewController
        self.version = Date().timeIntervalSince1970
        self.configuration = configuration
    }

    public static func == (lhs: UIElement, rhs: UIElement) -> Bool {
        lhs.identifier == rhs.identifier && lhs.version == rhs.version
    }
}

public protocol ComposableInterface {
    var composedElements: [UIElement] { get }
    var elementSorter: ((UIElement, UIElement) -> Bool)? { get }

    func composeInterface(elements: [UIElement])
}

public typealias ComposableInterfaceObject = ComposableInterface & AnyObject

// MARK: - Adapter

public struct UIComposableAdapter: ComposableInterface {
    weak var object: ComposableInterfaceObject?

    public var composedElements: [UIElement] {
        object?.composedElements ?? []
    }

    public var elementSorter: ((UIElement, UIElement) -> Bool)? {
        object?.elementSorter
    }

    public func composeInterface(elements: [UIElement]) {
        object?.composeInterface(elements: elements)
    }
}

// MARK: - Actions

public enum UIElementAction {
    case update(element: UIElement)
    case reload(identifier: String)
    case removeContent(identifier: String)
    case updateConfiguration(identifier: String, configuration: Any?)

    var identifier: String {
        switch self {
        case let .update(element: element):
            return element.identifier
        case let .reload(identifier: uid):
            return uid
        case let .removeContent(identifier: uid):
            return uid
        case let .updateConfiguration(identifier: uid, configuration: _):
            return uid
        }
    }
}

extension ComposableInterface {
    public var elementSorter: ((UIElement, UIElement) -> Bool)? { nil }

    public func putUIElementAction(_ action: UIElementAction) {
        var newElements = composedElements

        var currentElement: UIElement?

        if let index = newElements.firstIndex(where: { current in
            current.identifier == action.identifier
        }) {
            currentElement = newElements[index]
        }

        var newElement: UIElement?
        switch action {
        case let .update(element: element):
            newElement = element
        case .reload:
            newElement = currentElement?.reloaded
        case .removeContent:
            newElement = currentElement?.contentRemoved
        case let .updateConfiguration(identifier: _, configuration: config):
            newElement = currentElement?.configurationUpdated(config)
        }

        if let element = newElement {
            if let index = newElements.firstIndex(where: { current in
                current.identifier == action.identifier
            }) {
                newElements[index] = element
            } else {
                newElements.append(element)
            }

            if let sorter = elementSorter {
                newElements.sort(by: sorter)
            }

            composeInterface(elements: newElements)
        } else {
            assertionFailure("Cannot perform action \(action) due to properly element not found")
        }
    }
}

// MARK: - Mutate element

extension UIElement {
    public var reloaded: UIElement {
        var newElement = self
        newElement.version = Date().timeIntervalSince1970
        return newElement
    }

    public var contentRemoved: UIElement {
        var newElement = self
        newElement.version = Date().timeIntervalSince1970
        newElement.contentViewController = nil
        return newElement
    }

    public func configurationUpdated(_ configuration: Any?) -> UIElement {
        var newElement = self
        newElement.version = Date().timeIntervalSince1970
        newElement.configuration = configuration
        return newElement
    }
}
