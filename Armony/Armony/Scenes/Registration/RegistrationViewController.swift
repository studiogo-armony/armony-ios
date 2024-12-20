//
//  RegistrationViewController.swift
//  Armony
//
//  Created by Koray Yıldız on 1.02.2022.
//

import UIKit

protocol RegistrationViewDelegate: AnyObject, NavigationBarCustomizing {
    func configureUI()
    func startOkButtonActivityIndicatorView()
    func stopOkButtonActivityIndicatorView()
}

final class RegistrationViewController: UIViewController, ViewController {

    static var storyboardName: UIStoryboard.Name = .registration

    @IBOutlet private weak var navigationBarImageView: UIImageView!
    @IBOutlet private weak var gradientView: GradientView!
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var nameTextField: ValidatableTextField!
    @IBOutlet private weak var emailTextField: ValidatableTextField!
    @IBOutlet private weak var passwordTextField: ValidatableTextField!
    @IBOutlet private weak var linkLabel: TYLinkLabel!

    @IBOutlet private weak var okayButton: UIButton!
    @IBOutlet private weak var goLoginButton: UIButton!


    private lazy var validationResponders: ValidationResponders = {
        return ValidationResponders(required: [nameTextField, emailTextField, passwordTextField])
    }()

    var viewModel: RegistrationViewModel!

    private lazy var hideShowPasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(hideShowPasswordButtonTapped), for: .touchUpInside)
        button.setImage(hideShowPasswordButtonImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant:  40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(hideShowPasswordButtonTapped), for: .touchUpInside)
        button.setImage(hideShowPasswordButtonImage, for: .normal)
        return button
    }()

    private var hideShowPasswordButtonImage: UIImage {
        if passwordTextField.isSecureTextEntry {
            return .registrationPasswordHiddenIcon
        }
        else {
            return .registrationPasswordShowIcon
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()

        view.addTapGestureRecognizer { _ in
            self.view.endEditing(true)
        }

        okayButton.backgroundColor = UIColor.armonyPurple.withAlphaComponent(AppTheme.Alpha.low.rawValue)
        okayButton.isEnabled = false

        validationResponders.didValidate = { [weak self] result in
            self?.okayButton.isEnabled = result.isValid
            self?.okayButton.backgroundColor = result.isValid ? .armonyPurple : .armonyPurpleLow
        }

        configureTermsAndConditionLabel()
    }

    @IBAction private func okayButtonTapped() {
        let credential = SignupCredential(
            name: nameTextField.text.emptyIfNil,
            email: emailTextField.text.emptyIfNil,
            password: passwordTextField.text.emptyIfNil
        )
        viewModel.signup(credential: credential)
    }

    @IBAction private func goLoginButtonTapped() {
        viewModel.coordinator.dismiss(animated: true) { [weak self] in
            self?.viewModel.coordinator.login(loginCompletion: self?.viewModel.loginCompletion,
                                              registrationCompletion: self?.viewModel.registrationCompletion)
        }
    }

//    MARK: - Configuration TextFields
    private func configureNameTextField() {
        nameTextField.placeholder = "İsim Soyisim" // TODO: - Localizable

        nameTextField.autocapitalizationType = .words
        nameTextField.autocorrectionType = .no

        nameTextField.rules = ValidationRuleSet(
            rules: [
                Validation.Rule.Length(min: 3, max: 40, error: "En az 3 en fazla 40 karakter giriniz")
            ]
        )

        okayButton.setTitle("Üye Ol".needLocalization, for: .normal)
        okayButton.setTitleColor(.armonyWhite, for: .normal)
        okayButton.setTitleColor(.armonyWhite.withAlphaComponent(AppTheme.Alpha.medium.rawValue), for: .disabled)
        okayButton.titleLabel?.font = .semiboldHeading

        goLoginButton.setTitle("Zaten Üyeliğim Var".needLocalization, for: .normal)
        goLoginButton.titleLabel?.font = .lightBody
        goLoginButton.setTitleColor(.armonyWhite, for: .normal)
    }

    private func configureEmailTextField() {
        emailTextField.placeholder = "E-posta".needLocalization
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress

        emailTextField.rules = ValidationRuleSet(
            rules: [
                ValidationRuleEmailRegex()
            ]
        )
    }

    private func configurePasswordTextField() {
        passwordTextField.placeholder = "Şifre".needLocalization

        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true

        passwordTextField.rightView = hideShowPasswordButton
        passwordTextField.rightViewMode = .always

        passwordTextField.rules = ValidationRuleSet(
            rules: [
                Validation.Rule.Length(min: 6, max: 300, error: "Şifreniz minimum 6 karakter olmalı")
            ]
        )
    }

    @objc private func hideShowPasswordButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        hideShowPasswordButton.setImage(hideShowPasswordButtonImage, for: .normal)
    }

    private func configureTextFields() {
        configureNameTextField()
        configureEmailTextField()
        configurePasswordTextField()
    }

    private func configureGradientView() {
        let gradientPresentation = GradientPresentation(orientation: .vertical, color: .login)
        gradientView.configure(with: gradientPresentation)
    }

    fileprivate func configureTermsAndConditionLabel() {
        let termsAndCondition = "Hizmet Şartları"
        let cookie = "Çerez Kullanımı"
        let nondisclosureAgreement = "Gizlilik Sözleşmesi"
        let fullText = "Kaydolduğunda Hizmet Şartları'nı ve Çerez Kullanımı dahil olmak üzere Gizlilik Sözleşmesi'ni kabul etmiş olursun."

        let termsAndConditionLink = LabelLink(title: termsAndCondition, color: .armonyBlue, font: .semiboldBody)
        let cookieLink = LabelLink(title: cookie, color: .armonyBlue, font: .semiboldBody)
        let nondisclosureAgreementLink = LabelLink(title: nondisclosureAgreement, color: .armonyBlue, font: .semiboldBody)

        linkLabel.textColor = .armonyWhite
        linkLabel.font = .lightBody

        linkLabel.add([termsAndConditionLink, cookieLink, nondisclosureAgreementLink])
        linkLabel.text = fullText
        let webCoordinator = WebCoordinator(navigator: navigationController)
        linkLabel.handleAllTaps { tappedLink in
            switch tappedLink {
            case termsAndConditionLink:
                let url = "https://armony.app/sartlar-ve-kosullar.html"
                webCoordinator.start(with: url, title: "Şartlar ve Koşullar")

            case cookieLink:
                let url = "https://armony.app/sartlar-ve-kosullar.html"
                webCoordinator.start(with: url, title: "Şartlar ve Koşullar")

            case nondisclosureAgreementLink:
                let url = "https://armony.app/gizlilik-sozlesmesi.html"
                webCoordinator.start(with: url, title: "Gizlilik Sözleşmesi")

            default:
                break
            }
        }
    }
}

// MARK: - RegistrationViewDelegate
extension RegistrationViewController: RegistrationViewDelegate {

    func configureUI() {
        view.backgroundColor = .armonyBlack
        titleLabel.font = .semiboldTitle
        titleLabel.textColor = .armonyWhite
        navigationBarImageView.setAlpha(.medium)
        configureGradientView()
        configureTextFields()
    }

    func startOkButtonActivityIndicatorView() {
        okayButton.startActivityIndicatorView()
    }

    func stopOkButtonActivityIndicatorView() {
        okayButton.stopActivityIndicatorView()
    }
}
