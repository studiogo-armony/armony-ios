//
//  MockAdvertsView.swift
//  ArmonyTests
//
//  Created by Koray Yildiz on 17.08.26.
//

import UIKit
@testable import Armony

final class MockAdvertsView: AdvertsViewDelegate {

    // MARK: - configureCollectionView
    var invokedConfigureCollectionView = false
    func configureCollectionView() { invokedConfigureCollectionView = true }

    // MARK: - configureNavigationBar
    var invokedConfigureNavigationBar = false
    func configureNavigationBar() { invokedConfigureNavigationBar = true }

    // MARK: - configureUI
    var invokedConfigureUI = false
    func configureUI() { invokedConfigureUI = true }

    // MARK: - reloadCollectionView
    var invokedReloadCollectionView = false
    var invokedReloadCollectionViewCount = 0
    var onReloadCollectionView: VoidCallback?
    func reloadCollectionView() {
        invokedReloadCollectionView = true
        invokedReloadCollectionViewCount += 1
        onReloadCollectionView?()
    }

    // MARK: - setCollectionViewVisibility
    var invokedSetCollectionViewVisibility = false
    var invokedSetCollectionViewVisibilityCount = 0
    var invokedSetCollectionViewVisibilityParameters: (isHidden: Bool, animated: Bool)?
    func setCollectionViewVisibility(isHidden: Bool, animated: Bool) {
        invokedSetCollectionViewVisibility = true
        invokedSetCollectionViewVisibilityCount += 1
        invokedSetCollectionViewVisibilityParameters = (isHidden, animated)
    }

    // MARK: - deleteItems
    var invokedDeleteItems = false
    func deleteItems(indexPaths: [IndexPath], completion: @escaping Callback<Bool>) {
        invokedDeleteItems = true
        completion(true)
    }

    // MARK: - insertItems
    var invokedInsertItems = false
    func insertItems(indexPaths: [IndexPath], completion: @escaping Callback<Bool>) {
        invokedInsertItems = true
        completion(true)
    }

    // MARK: - ActivityIndicatorShowing
    var invokedStartActivityIndicatorView = false
    func startActivityIndicatorView() { invokedStartActivityIndicatorView = true }

    var invokedStopActivityIndicatorView = false
    var invokedStopActivityIndicatorViewCount = 0
    var onStopActivityIndicatorView: VoidCallback?
    func stopActivityIndicatorView() {
        invokedStopActivityIndicatorView = true
        invokedStopActivityIndicatorViewCount += 1
        onStopActivityIndicatorView?()
    }

    // MARK: - EmptyStateShowing
    var containerEmptyStateView: UIView = UIView()

    var invokedShowEmptyStateView = false
    func showEmptyStateView(with presentation: EmptyStatePresentation, action: Callback<UIButton>?) {
        invokedShowEmptyStateView = true
    }

    var invokedHideEmptyStateView = false
    func hideEmptyStateView(animated: Bool) { invokedHideEmptyStateView = true }

    // MARK: - RefreshControlShowing
    var containerScrollView: UIScrollView = UIScrollView()

    var invokedAddRefresher = false
    func addRefresher(_ target: Any, color: UIColor, selector: Selector) { invokedAddRefresher = true }

    var invokedEndRefreshing = false
    func endRefreshing() { invokedEndRefreshing = true }
}
