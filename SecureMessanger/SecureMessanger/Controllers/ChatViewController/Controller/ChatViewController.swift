//
//  ChatViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.03.2022.
//

import UIKit

class ChatViewController: UIViewController {
    
    var chat: Chat?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }


    private func setupView() {
        rootView?.backAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

}

extension ChatViewController: RootViewGettable {
    typealias RootViewType = ChatView
}
