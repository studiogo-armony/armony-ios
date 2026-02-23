//
//  Analytic.swift
//  Armony
//
//  Created by Koray Yıldız on 28.11.22.
//

import Foundation

protocol EventSendable {
    func send()
}

protocol Analytic {
    associatedtype Event

    func send(event: Event)
}

protocol Event: EventSendable {
    var shouldRemoveIfEventValueEmpty: Bool { get }
}

extension Event {
    var shouldRemoveIfEventValueEmpty: Bool {
        false
    }
}



