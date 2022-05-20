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
    private var chats: [Chat] = []
 
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
            guard let self = self else { return }
            
            progress.hide(animated: true)
            
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
    
}

//MARK: - RootViewGettable

extension ChatListViewController: RootViewGettable {
    typealias RootViewType = ChatListView
}

//MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < chats.count {
            showChatVC(chat: chats[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

//MARK: - UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rootView!.chatCellID, for: indexPath) as! ChatListTableViewCell
        if indexPath.row < chats.count {
            cell.configure(with: chats[indexPath.row])
        }
        return cell
    }
    
    
}
