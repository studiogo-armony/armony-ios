//
//  CreateAdvertViewController.swift
//  Armony
//
//  Created by Koray Yıldız on 04.10.22.
//

import UIKit

protocol CreateAdvertViewDelegate: AnyObject, NavigationBarCustomizing {
    func configureMusicGenreDropdownView(presentation: DropdownPresentation)
    func configureSkillDropdownView(presentation: DropdownPresentation)

    func updateAdvertType(title: String?)
    func updateSkills(title: String?)
    func updateLocation(title: String?)
    func updateMusicGenres(title: String?)

    func setInformationsStackViewVisibility(isHidden: Bool)

    func startAdvertTypeDropdownViewActivityIndicatorView()
    func stopAdvertTypeDropdownViewActivityIndicatorView()

    func startSkillsDropdownViewActivityIndicatorView()
    func stopSkillsDropdownViewActivityIndicatorView()

    func startMusicGenresDropdownViewActivityIndicatorView()
    func stopMusicGenresDropdownViewActivityIndicatorView()

    func startLocationDropdownViewActivityIndicatorView()
    func stopLocationDropdownViewActivityIndicatorView()

    func startSubmitButtonActivityIndicatorView()
    func stopSubmitButtonActivityIndicatorView()

    func resetTextView()
}

final class CreateAdvertViewController: UIViewController, ViewController {

    static var storyboardName: UIStoryboard.Name = .createAdvert

    @IBOutlet private weak var headerGradientView: GradientView!
    @IBOutlet private weak var navigationSubtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var advertTypesDropdownView: ValidatableDropdownView!

    @IBOutlet private weak var informationsStackView: UIStackView!
    @IBOutlet private weak var musicGenresDropdownView: ValidatableDropdownView!
    @IBOutlet private weak var skillsDropdownView: ValidatableDropdownView!
    @IBOutlet private weak var locationDropdownView: ValidatableDropdownView!
    @IBOutlet private weak var descriptionTextView: TextView!

    @IBOutlet private weak var submitButton: UIButton!

    var viewModel: CreateAdvertViewModel!

    private lazy var validationResponders = ValidationResponders(
        required: [
            advertTypesDropdownView, musicGenresDropdownView, skillsDropdownView, locationDropdownView
        ]
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .armonyBlack

        configureSubmitButton()
        makeNavigationBarTransparent()
        prepareDropdowns()
        prepareTitleLabels()

        setInformationsStackViewVisibility(isHidden: true)

        headerGradientView.configure(with: .init(orientation: .vertical, color: .profile))
        descriptionTextView.delegate = self
        let presentation = TextViewPresentation(
            placeholder: "Açıklama Ekle",
            numberOfMinimumChar: .zero,
            numberOfMaximumChar: 500
        )
        descriptionTextView.configure(with: presentation)

        view.addTapGestureRecognizer(cancelsTouches: false) { [weak self] _ in
            self?.view.endEditing(true)
        }

        validationResponders.didValidate = { [weak self] result in
            self?.submitButton.isEnabled = result.isValid
            self?.submitButton.backgroundColor = result.isValid ? .armonyPurple : .armonyPurpleLow
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeNavigationBarTransparent()
    }

    fileprivate func configureSubmitButton() {
        submitButton.isEnabled = false
        submitButton.setTitle("Yayına Al", for: .normal)
        submitButton.setTitleColor(.armonyWhite, for: .normal)
        submitButton.setTitleColor(.armonyWhiteMedium, for: .disabled)
        submitButton.titleLabel?.font = .semiboldHeading
        submitButton.backgroundColor = .armonyPurpleLow
        submitButton.makeAllCornersRounded(radius: .medium)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }

    @objc private func submitButtonTapped() {
        view.endEditing(true)
        viewModel.submitButtonTapped()
    }

    private func prepareDropdowns() {
        advertTypesDropdownView.configure(with: .advertType)
        advertTypesDropdownView.addTapGestureRecognizer(cancelsTouches: false) { [unowned self] _ in
            self.view.endEditing(true)
            self.viewModel.advertTypeDropdownTapped()
        }

        musicGenresDropdownView.configure(with: .musicGenres)
        musicGenresDropdownView.addTapGestureRecognizer { [unowned self] _ in
            self.view.endEditing(true)
            self.viewModel.musicGenresDropdownTapped()
        }

        skillsDropdownView.configure(with: .skill)
        skillsDropdownView.addTapGestureRecognizer { [unowned self] _ in
            self.view.endEditing(true)
            self.viewModel.skillsDropdownTapped()
        }

        locationDropdownView.configure(with: .location)
        locationDropdownView.addTapGestureRecognizer { [unowned self] _ in
            self.view.endEditing(true)
            self.viewModel.locationDropdownTapped()
        }
    }

    private func prepareTitleLabels() {
        navigationSubtitleLabel.font = .regularSubheading
        navigationSubtitleLabel.textColor = .armonyWhite

        titleLabel.font = .semiboldTitle
        titleLabel.textColor = .armonyWhite
    }
}

// MARK: - CreateAdvertViewDelegate
extension CreateAdvertViewController: CreateAdvertViewDelegate {
    func configureMusicGenreDropdownView(presentation: DropdownPresentation) {
        musicGenresDropdownView.configure(with: presentation)
    }

    func configureSkillDropdownView(presentation: DropdownPresentation) {
        skillsDropdownView.configure(with: presentation)
    }

    func updateAdvertType(title: String?) {
        advertTypesDropdownView.updateText(title)
    }

    func updateSkills(title: String?) {
        skillsDropdownView.updateText(title)
    }

    func updateLocation(title: String?) {
        locationDropdownView.updateText(title)
    }

    func updateMusicGenres(title: String?) {
        musicGenresDropdownView.updateText(title)
    }

    func setInformationsStackViewVisibility(isHidden: Bool) {
        informationsStackView.isHidden = isHidden
    }

    func startAdvertTypeDropdownViewActivityIndicatorView() {
        advertTypesDropdownView.startActivityIndicatorView()
    }

    func stopAdvertTypeDropdownViewActivityIndicatorView() {
        advertTypesDropdownView.stopActivityIndicatorView()
    }

    func startSkillsDropdownViewActivityIndicatorView() {
        skillsDropdownView.startActivityIndicatorView()
    }

    func stopSkillsDropdownViewActivityIndicatorView() {
        skillsDropdownView.stopActivityIndicatorView()
    }

    func startMusicGenresDropdownViewActivityIndicatorView() {
        musicGenresDropdownView.startActivityIndicatorView()
    }

    func stopMusicGenresDropdownViewActivityIndicatorView() {
        musicGenresDropdownView.stopActivityIndicatorView()
    }

    func startLocationDropdownViewActivityIndicatorView() {
        locationDropdownView.startActivityIndicatorView()
    }

    func stopLocationDropdownViewActivityIndicatorView() {
        locationDropdownView.stopActivityIndicatorView()
    }

    func startSubmitButtonActivityIndicatorView() {
        submitButton.startActivityIndicatorView()
    }

    func stopSubmitButtonActivityIndicatorView() {
        submitButton.stopActivityIndicatorView()
    }

    func resetTextView() {
        descriptionTextView.updateText(.empty)
    }
}

// MARK: - TextViewDelegate
extension CreateAdvertViewController: TextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.descriptionTextViewDidChange(description: textView.text)
    }
}

