//
//  ChatListViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class ChatListViewController: UIViewController {
    
    //MARK: - Variables
    
    //MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - Private methods
    
    
    
}

//MARK: - RootViewGettable

extension ChatListViewController: RootViewGettable {
    typealias RootViewType = ChatListView
}

//MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Chat.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rootView!.chatCellID, for: indexPath) as! ChatListTableViewCell
        if indexPath.row < Chat.data.count {
            cell.configure(with: Chat.data[indexPath.row])
        }
        return cell
    }
    
    
}
