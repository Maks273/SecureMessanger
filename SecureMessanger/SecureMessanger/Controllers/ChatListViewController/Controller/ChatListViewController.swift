//
//  ChatListViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit
import MBProgressHUD

class ChatListViewController: UIViewController {
    
    //MARK: - Variables
    
    private let dispatchGroup = DispatchGroup()
    private var searchedChats: [Chat] = []
    private var chats: [Chat] = [] {
        didSet {
            searchedChats = chats
        }
    }
 
    //MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadCurrentUser()
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.fetchChats()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = false
        fetchChats()
    
    }
    
    //MARK: - Private methods
    
    private func fetchChats(showRefresh: Bool = true) {
        guard let _ = CredentialManager.sharedInstance.currentUser?.hash else { return }
        
        var progress: MBProgressHUD?
        
        if showRefresh {
            progress = MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        ApiService.shared.fetchChats { [weak self] chats, error in
            progress?.hide(animated: true)
            self?.rootView?.stopRefreshControl()
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else {
                self.chats = chats
                self.setReciveStatus()
                self.rootView?.reloadTableView()
            }
            
        }
    }
    
    private func setupView() {
        rootView?.refreshAction = { [weak self] in
            self?.fetchChats(showRefresh: false)
            
        }
        
        rootView?.createChatAction = { [weak self] in
            self?.showCreateChatVC()
        }
    }
    
    private func loadCurrentUser() {
        guard let phoneNumber = CredentialManager.sharedInstance.getPhone() else {
            fatalError()
        }
        
        let udid = UIDevice.current.identifierForVendor!.uuidString
        dispatchGroup.enter()
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.fetchUser(phone: phoneNumber, deviceInfo: udid) { [weak self] user, error in
            self?.dispatchGroup.leave()
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }
            
            CredentialManager.sharedInstance.currentUser = user
        }
    }
    
    private func showCreateChatVC() {
        let vc = CreateChatViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
   
    
    private func showChatVC(chat: Chat) {
        let vc = ChatViewController()
        vc.chat = chat
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func performChatSearch(_ text: String) {
        searchedChats = chats.filter { $0.chat.name.contains(text) }
        if text.isEmpty {
            searchedChats = chats
        }
        rootView?.reloadTableView()
    }
    
    private func deleteChat(with id: Int) {
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.deleteChat(chatId: id) { [weak self] success, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if success == true {
                self.searchedChats.removeAll(where: { $0.chat.id == id })
                self.chats.removeAll(where: { $0.chat.id == id })
                self.rootView?.reloadTableView()
            }
        }
    }
    
    private func setReciveStatus() {
        let ids = self.chats.filter { $0.chat.unrecievedCount > 0 }
        guard !ids.isEmpty else { return }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.setReciveChat(chatIds: ids.map { $0.chat.id }) { [weak self] success, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }
            
        }
    }
    
}

//MARK: - RootViewGettable

extension ChatListViewController: RootViewGettable {
    typealias RootViewType = ChatListView
}

//MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < searchedChats.count {
            showChatVC(chat: searchedChats[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < searchedChats.count else { return nil }
        
        let chat = searchedChats[indexPath.row]
    
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            self?.deleteChat(with: chat.chat.id)
        }
        
        let me = chat.members.first(where: { $0.userId == CredentialManager.sharedInstance.currentUser?.id })
        
        return chat.chat.type == 1 || me?.type == 1 ? UISwipeActionsConfiguration(actions: [deleteAction]) : nil // private chat || i'm an admin
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchedChats.isEmpty ? tableView.frame.height/2 : 0
    }
}

//MARK: - UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rootView!.chatCellID, for: indexPath) as! ChatListTableViewCell
        if indexPath.row < searchedChats.count {
            cell.configure(with: searchedChats[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TableViewPlaceholderView()
        view.configure(title: "No chats in your messages list")
        return searchedChats.isEmpty ? view : nil
    }
    
    
}

extension ChatListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performChatSearch(textField.text ?? "")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldRange = NSRange(location: 0, length: textField.text?.count ?? 0)
        if NSEqualRanges(range, textFieldRange) && string.isEmpty {
            performChatSearch("")
        }
        return true
    }
    
}
