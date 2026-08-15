//
//  AdvertCoordinating.swift
//  Armony
//
//  Created by Koray Yıldız on 13.08.26.
//

import Foundation

protocol AdvertCoordinating: CoordinatorInterface {
    func visitedAccount(with userID: String)
    func liveChat(with chatID: Int)
    func registration(didRegister: VoidCallback?, didLogin: VoidCallback?)
    func selectionBottomPopUp(presentation: any SelectionPresentation)
    func openAtSafariViewController(url: URL)
    func dismiss(animated: Bool, completion: VoidCallback?)
}
