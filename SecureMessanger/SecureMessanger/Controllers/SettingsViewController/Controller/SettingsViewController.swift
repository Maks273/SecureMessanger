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
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        rootView?.logoutAction = {
            CredentialManager.sharedInstance.reset()
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let navController = UINavigationController(rootViewController: WelcomeViewController())
            sceneDelegate?.window?.rootViewController = navController
            sceneDelegate?.window?.makeKeyAndVisible()
        }
    }


}

extension SettingsViewController: RootViewGettable {
    typealias RootViewType = SettingsView
}
