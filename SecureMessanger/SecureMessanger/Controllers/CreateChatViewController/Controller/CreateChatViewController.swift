//
//  CreateChatViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 19.05.2022.
//

import UIKit
import MBProgressHUD

class CreateChatViewController: UIViewController {
    
    private var members: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create a chat"
        setupDefaultBackButton()
        setupView()
        setupFindUserButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupView() {
        rootView?.createChatAction = { [weak self] in
            self?.createChat()
        }
    }
    
    private func setupFindUserButton() {
        let rightButton = UIButton()
        rightButton.setImage(UIImage(systemName: "plus"), for: .normal)
        rightButton.tintColor = UIColor(named: "#2F385D")
        rightButton.addTarget(self, action: #selector(addMemberButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    @objc private func addMemberButtonPressed() {
        showFindMemberVC()
    }
    
    private func showFindMemberVC() {
        let vc = FindMemberViewController()
        vc.didSelectMember = { [weak self] member in
            self?.members.append(member)
            self?.rootView?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createChat() {
        guard !members.isEmpty else {
            showAlert(title: "Warning", message: "There should be minimun one member", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        
        let chatType = members.count > 1 ? 2 : 1 // 1 means private chat
        var chatName: String?
        
        if chatType == 2 {
            showTextFieldAlert(title: "Please, input a group chat name", okTitle: "Save") { text in
                chatName = text
            }
        }else {
            chatName = nil
        }
        
        let chatEntity = CreateCharEntity(name: chatName, type: chatType)
        
        var membersEntities: [CreateChatMemberEntity] = []
        members.append(CredentialManager.sharedInstance.currentUser!)
        members.forEach { member in
            let isCurrent = CredentialManager.sharedInstance.currentUser?.id == member.id
            membersEntities.append(CreateChatMemberEntity(type: isCurrent ? 1 : 2, fromUserId: CredentialManager.sharedInstance.currentUser!.id, userId: isCurrent ? CredentialManager.sharedInstance.currentUser!.id : member.id))
        }
        
        members.removeLast()
        
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.createChat(model: CreateChatRequest(chat: chatEntity, members: membersEntities)) { [weak self] chat, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else if let chat = chat {
                self.showChatVC(model: chat)
            }
        }
        
        
    }
    
    private func showChatVC(model: Chat?) {
        let vc = ChatViewController()
        vc.chat = model
        navigationController?.popViewController(animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension CreateChatViewController: RootViewGettable {
    typealias RootViewType = CreateChatView
}

extension CreateChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            guard let self = self, indexPath.row < self.members.count else { return }
            self.members.remove(at: indexPath.row)
            self.rootView?.tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CreateChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rootView!.cellID, for: indexPath) as! MemberTableViewCell
        if indexPath.row < members.count {
            cell.configure(model: members[indexPath.row])
        }
        return cell
    }
}
