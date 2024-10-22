//
//  VisitedAccountMediasViewController.swift
//  Armony
//
//  Created by Koray Yıldız on 18.10.2023.
//

import UIKit

final class VisitedAccountMediasViewController: UIViewController, ViewController, ActivityIndicatorShowing {

    static var storyboardName: UIStoryboard.Name = .none

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    var viewModel: VisitedAccountMediasViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareViews()
        viewModel.fetchMedias()

        viewModel.didFetchMedias = { [weak self] in
            safeSync {
                self?.tableView.isHidden = false
                self?.stopActivityIndicatorView()
                self?.tableView.reloadData()
            }
        }
    }

    fileprivate func prepareViews() {
        view.addSubviewAndConstraintsToSafeArea(tableView)

        view.backgroundColor = .armonyBlack
        startActivityIndicatorView()

        tableView.registerCells(cells: [VisitedAccountYoutubeMediaCell.self])
        tableView.isHidden = true
    }
}

// MARK: - UITableViewDelegate
extension VisitedAccountMediasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * 0.6
    }
}

// MARK: - UITableViewDataSource
extension VisitedAccountMediasViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.presentation.medias.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VisitedAccountYoutubeMediaCell()
        let videoID = viewModel.presentation.medias[indexPath.row].videoID
        cell.configure(with: videoID)
        return cell
    }
}
