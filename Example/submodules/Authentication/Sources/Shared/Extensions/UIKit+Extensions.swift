//
//  Extensions.swift
//  Modular
//
//  Created by BOARDY on 5/31/21.
//

import UIKit

func feedbackHaptic() {
    let haptic = UISelectionFeedbackGenerator()
    haptic.prepare()
    haptic.selectionChanged()
}

func notificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let haptic = UINotificationFeedbackGenerator()
    haptic.prepare()
    haptic.notificationOccurred(type)
}
