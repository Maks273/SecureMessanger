//
//  SettingsViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootView?.updateView()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupView() {
        rootView?.logoutAction = {
            CredentialManager.sharedInstance.reset()
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let navController = UINavigationController(rootViewController: WelcomeViewController())
            sceneDelegate?.window?.rootViewController = navController
            sceneDelegate?.window?.makeKeyAndVisible()
        }
        
        rootView?.editAction = { [weak self] in
            self?.showProfileSettingsVC()
        }
    }
    
    private func showProfileSettingsVC() {
        let vc = ProfileSettingsViewController()
        vc.phoneNumber = CredentialManager.sharedInstance.currentUser?.phone
        navigationController?.pushViewController(vc, animated: true)
    }


}

extension SettingsViewController: RootViewGettable {
    typealias RootViewType = SettingsView
}
