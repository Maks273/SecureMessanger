//
//  ChatDetailViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 22.05.2022.
//

import UIKit
import MBProgressHUD

class ChatDetailViewController: UIViewController {
    
    var chat: Chat?
    private var currentControlIndex: Int = 0 {
        didSet {
            rootView?.changeSelectionStyle(index: currentControlIndex)
            rootView?.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configureView() {
        guard let chat = chat?.chat else { return }
        let user = self.chat?.members.first(where: { $0.userId != CredentialManager.sharedInstance.currentUser?.id })
        rootView?.configure(chatName: chat.name, imageURL: "", phoneNumber: chat.type == 1 ? user?.userPhone : nil)
        currentControlIndex = chat.type == 1 ? 1 : 0
        rootView?.addMemberAction = { [weak self] in
            self?.showFindMemberVC()
        }
        
        rootView?.controlAction = { [weak self] index in
            self?.currentControlIndex = index
        }
    }
    
    private func showFindMemberVC() {
        let vc = FindMemberViewController()
        vc.didSelectMember = { [weak self] member in
            self?.addMember(user: member)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func deleteMember(at index: IndexPath) {
        guard let userId = chat?.members[index.row].userId, let chatId = chat?.chat.id else { return }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.deleteChatMember(chatId: chatId, memberId: userId) { [weak self] success, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if success == true {
                self.chat?.members.removeAll(where: { $0.userId == userId })
                self.rootView?.tableView.reloadData()
            }
        }
    }
    
    private func addMember(user: User) {
        guard let chatId = chat?.chat.id else { return }
                
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.addChatMember(chatId: chatId, memberId: user.id) { [weak self] success, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if success == true {
                //self.chat?.members.removeAll(where: { $0.userId == userId })
                self.rootView?.tableView.reloadData()
            }
        }
    }
    
    

}

extension ChatDetailViewController: RootViewGettable {
    typealias RootViewType = ChatDetailView
}

extension ChatDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            guard let self = self, indexPath.row < (self.chat?.members.count ?? 0) else { return }
            self.deleteMember(at: indexPath)
        }
        return currentControlIndex == 0 && chat!.chat.type == 2 ? UISwipeActionsConfiguration(actions: [deleteAction]) : nil
    }
}

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentControlIndex {
        case 0:
            return chat?.members.count ?? 0
        case 1:
            return 0
        case 2:
            return 0
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rootView!.contactCellID, for: indexPath) as! ContactListTableViewCell
        if indexPath.row < (chat?.members.count ?? 0) {
            cell.configure(with: chat!.members[indexPath.row])
        }
        return cell
    }
}
