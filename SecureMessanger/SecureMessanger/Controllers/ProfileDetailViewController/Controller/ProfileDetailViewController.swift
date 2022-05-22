//
//  ProfileDetailViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.05.2022.
//

import UIKit
import MBProgressHUD

class ProfileDetailViewController: UIViewController {
    
    var user: User?
    var didUpdateUser: ((User) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configureView() {
        guard let user = user else { return }
        
        rootView?.configure(model: user)
        
        rootView?.messageAction = { [weak self] in
            self?.startChat()
        }
        
        rootView?.connectAction = { [weak self] in
            self?.user?.isContact == true ? self?.deleteContact() : self?.addContact()
        }
        
        rootView?.setConnectButtonTitle(user.isContact == true ? "Delete" : "Add")
        
    }
    
    private func startChat() {
        guard let user = user else { return }
        
        let members = [CredentialManager.sharedInstance.currentUser!, user]
        
        let chatType = 1 // 1 means private chat

        let chatEntity = CreateCharEntity(name: nil, type: chatType)
        
        var membersEntities: [CreateChatMemberEntity] = []

        members.forEach { member in
            let isCurrent = CredentialManager.sharedInstance.currentUser?.id == member.id
            membersEntities.append(CreateChatMemberEntity(type: isCurrent ? 1 : 2, fromUserId: CredentialManager.sharedInstance.currentUser!.id, userId: isCurrent ? CredentialManager.sharedInstance.currentUser!.id : member.id))
        }
        
        
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
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addContact() {
        guard let id = user?.id else { return }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.addUserInContacts(id: id) { [weak self] success, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else if success == true {
                self.showAlert(title: "Success", message: "Successfuly added the user into your contacts", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
                self.rootView?.setConnectButtonTitle("Delete")
                self.didUpdateUser?(self.user!)
            }
        }
    }
    
    private func deleteContact() {
        guard let id = user?.id else { return }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.deleteUserFromContacts(id: id) { [weak self] success, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else if success == true {
                self.showAlert(title: "Success", message: "Successfuly deleted the user from your contacts", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
                self.rootView?.setConnectButtonTitle("Add")
                self.didUpdateUser?(self.user!)
            }
        }
        
    }
}


extension ProfileDetailViewController: RootViewGettable {
    typealias RootViewType = ProfileDetailView
}
