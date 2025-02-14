//
//  ChatsViewController.swift
//  Armony
//
//  Created by Koray Yıldız on 16.11.22.
//

import UIKit
import UIScrollView_InfiniteScroll

protocol ChatsViewDelegate: AnyObject, NavigationBarCustomizing, EmptyStateShowing, ActivityIndicatorShowing, RefreshControlShowing {
    func reloadData()
    func setTableViewVisibility(isHidden: Bool)
}

final class ChatsViewController: UIViewController, ViewController {

    static var storyboardName: UIStoryboard.Name = .chat

    @IBOutlet private weak var tableView: UITableView!

    var viewModel: ChatsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        viewModel.viewDidLoad()
        view.backgroundColor = .armonyBlack

        tableView.infiniteScrollIndicatorView = UIActivityIndicatorView.create(color: .armonyWhite, style: .medium)

        tableView.addInfiniteScroll { [unowned self] _ in
            self.viewModel.next()
            tableView.finishInfiniteScroll()
        }

        tableView.setShouldShowInfiniteScrollHandler { [unowned self] _ -> Bool in
            return viewModel.hasNextPage
        }

        addRefresher(self, color: AppTheme.Color.green, selector: #selector(refresh))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenView()
    }

    @objc private func refresh() {
        viewModel.fetchMessages()
    }

    fileprivate func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(horizontal: .zero, vertical: 10.0)
        tableView.registerCells(cells: [ChatCell.self])
    }
}

// MARK: - UITableViewDataSource
extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatCell = tableView.dequeueReusableCell(for: indexPath)
        let message = viewModel.message(at: indexPath)
        cell.configure(with: message)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return RemoteConfigService.shared[.isDeleteChatActive]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AlertService.show(
                title: String("Chat.Delete.Alert.Title", table: .chat),
                message: String("Chat.Delete.Alert.Message", table: .chat),
                actions: [
                    .cancel(),
                    AlertService.action(title: String("Chat.Delete.Button", table: .chat), style: .destructive, action: { [weak self] in
                        self?.viewModel.deleteMessage(at: indexPath)
                    })
                ]
            )
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return String("Chat.Delete.Button", table: .chat)
    }
}

// MARK: - UITableViewDataSource
extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !viewModel.message(at: indexPath).isRead {
            guard let selectedCell = tableView.cellForRow(at: indexPath) as? ChatCell else { return }
            selectedCell.hideUnreadIcon()
        }
        viewModel.coordinator.chat(id: viewModel.message(at: indexPath).id)
    }
}

// MARK: - MessagesViewDelegate
extension ChatsViewController: ChatsViewDelegate {
    var containerScrollView: UIScrollView {
        tableView
    }

    var containerEmptyStateView: UIView {
        tableView
    }

    func reloadData() {
        tableView.reloadData()
    }

    func setTableViewVisibility(isHidden: Bool) {
        tableView.setHidden(isHidden, animated: true)
    }
}
