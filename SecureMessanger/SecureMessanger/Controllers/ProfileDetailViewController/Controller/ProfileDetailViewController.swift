//
//  ProfileDetailViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.05.2022.
//

import UIKit

class ProfileDetailViewController: UIViewController {
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            
        }
        
        
    }
}


extension ProfileDetailViewController: RootViewGettable {
    typealias RootViewType = ProfileDetailView
}
