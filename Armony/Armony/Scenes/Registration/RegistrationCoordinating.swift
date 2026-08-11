//
//  RegistrationCoordinating.swift
//  Armony
//
//  Created by Koray Yıldız on 12.08.26.
//

import UIKit

protocol RegistrationCoordinating: CoordinatorInterface {
    func login(loginCompletion: VoidCallback?, registrationCompletion: VoidCallback?)
}
