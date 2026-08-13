//
//  LoginCoordinating.swift
//  Armony
//
//  Created by Koray Yıldız on 13.08.26.
//

protocol LoginCoordinating: CoordinatorInterface {
    func showForgotPasswordView(email: String, actionButtonTapped: Callback<String>?)
    func registration(registrationCompletion: VoidCallback?, loginCompletion: VoidCallback?)
}
