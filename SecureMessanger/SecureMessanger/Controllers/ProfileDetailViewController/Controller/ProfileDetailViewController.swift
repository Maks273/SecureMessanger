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
            
        }
        
    }
    
    private func startChat() {
        guard let user = user else { return }
        
        let members = [CredentialManager.sharedInstance.currentUser!, user]
        
        let chatType = members.count > 1 ? 2 : 1 // 1 means private chat
//не добре, створює новий чат, DEBUGGG
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
        //navigationController?.popViewController(animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension ProfileDetailViewController: RootViewGettable {
    typealias RootViewType = ProfileDetailView
}
