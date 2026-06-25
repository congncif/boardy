//
//  AlertBoard.swift
//  Boardy
//
//  Created by CONGNC7 on 11/05/2022.
//

import Foundation
import UIKit

public struct AlertAction {
    public init(title: String, style: AlertAction.Style = .default, shouldBePreferred: Bool = false, handler: (() -> Void)?) {
        self.title = title
        self.style = style
        self.shouldBePreferred = shouldBePreferred
        self.handler = handler
    }

    public init<Target: AnyObject>(title: String, style: AlertAction.Style = .default, shouldBePreferred: Bool = false, target: Target, handler: ((Target) -> Void)?) {
        self.title = title
        self.style = style
        self.shouldBePreferred = shouldBePreferred
        self.handler = { [weak target] in
            guard let target = target else { return }
            handler?(target)
        }
    }

    public enum Style {
        case `default`
        case cancel
        case destructive
    }

    let title: String
    let style: Style
    let shouldBePreferred: Bool
    let handler: (() -> Void)?
}

public struct Alert {
    public init(title: String? = nil, message: String?, style: Alert.Style = .alert, actions: [AlertAction]) {
        self.title = title
        self.message = message
        self.style = style
        self.actions = actions
    }

    public enum Style {
        case alert
        case actionSheet
    }

    let title: String?
    let message: String?
    let style: Style
    let actions: [AlertAction]
}

final class AlertBoard: Board, GuaranteedBoard {
    typealias InputType = Alert

    private var didComplete = false
    private var presentationDelegate: AlertPresentationDelegate?

    func activate(withGuaranteedInput input: Alert) {
        didComplete = false
        let alertController = UIAlertController(title: input.title, message: input.message, preferredStyle: input.style.alertStyle)
        let actions = input.actions.isEmpty ? [AlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)] : input.actions

        actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.style.actionStyle) { [weak self, action] _ in
                action.handler?()
                self?.completeAlert(action.style != .cancel)
            }
            alertController.addAction(alertAction)
            if action.shouldBePreferred {
                alertController.preferredAction = alertAction
            }
        }

        let delegate = AlertPresentationDelegate { [weak self] in
            self?.completeAlert(false)
        }
        presentationDelegate = delegate
        alertController.presentationController?.delegate = delegate

        rootViewController.boardy_topPresentedViewController.present(alertController, animated: true, completion: nil)
    }

    func shouldBypassGatewayBarrier() -> Bool {
        true
    }

    private func completeAlert(_ isDone: Bool) {
        guard !didComplete else { return }
        didComplete = true
        presentationDelegate = nil
        complete(isDone)
    }
}

private final class AlertPresentationDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    private let dismissHandler: () -> Void

    init(dismissHandler: @escaping () -> Void) {
        self.dismissHandler = dismissHandler
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissHandler()
    }
}

extension Alert.Style {
    var alertStyle: UIAlertController.Style {
        switch self {
        case .alert:
            return .alert
        case .actionSheet:
            return .actionSheet
        }
    }
}

extension AlertAction.Style {
    var actionStyle: UIAlertAction.Style {
        switch self {
        case .default:
            return .default
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

public extension MotherboardType {
    func activateAlert(_ alert: Alert) {
        let identifier = identifier.appending("___ALERT___").appending(UUID().uuidString)
        let alertBoard = AlertBoard(identifier: identifier)
        installBoard(alertBoard)
        DebugLog.logActivation(source: self, destination: alertBoard, data: alert)
        alertBoard.activate(withOption: alert)
    }
}
