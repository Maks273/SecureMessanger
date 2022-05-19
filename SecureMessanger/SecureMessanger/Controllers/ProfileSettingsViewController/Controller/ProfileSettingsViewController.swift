//
//  ProfileSettingsViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit
import MBProgressHUD

class ProfileSettingsViewController: UIViewController {
    
    //MARK: - Variabels
    
    var phoneNumber: String?
    private let bioCharLimit = 120
    private var currentLine = 1
    private var shouldReloadInputUI: Bool = false {
        didSet {
            let height: CGFloat = 40 + (currentLine == 1 ? 0 : CGFloat(currentLine * 8))
            rootView?.setBioTextViewHeight(height)
        }
    }
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        configureView()
        title = "Profile settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
        fillData()
    }
    
    //MARK: - Private methods
    
    private func configureView() {
        rootView?.setupPhoneNumber(phoneNumber)
        rootView?.saveAction = { [weak self] in
            guard let self = self else { return }
            self.updateUser()
        }
    }
    
    private func updateUser() {
        
        let username = rootView?.getUserName()
        let bio = rootView?.getUserBio()
        let image = rootView?.getUserImage()
        
        guard username?.isEmpty == false else  {
            showAlert(title: "Warning", message: "The username can't be empty", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }

        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        ApiService.shared.updateUser(UpdateUserRequest(name: username, description: bio)) { [weak self] user, error in
            progress.hide(animated: true)
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if let user = user {
                CredentialManager.sharedInstance.currentUser = user
                if self.tabBarController == nil {
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    sceneDelegate?.window?.rootViewController = MainTabBarViewController()
                    sceneDelegate?.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    private func fillData() {
        let user = CredentialManager.sharedInstance.currentUser
        rootView?.setName(user?.name)
        rootView?.setupPhoneNumber(user?.phone)
        rootView?.setBioInfo(user?.description)
        rootView?.setUserImage(user?.avatarUrl)
    }
}

//MARK: - RootViewGettable

extension ProfileSettingsViewController: RootViewGettable {
    typealias RootViewType = ProfileSettingsView
}


extension ProfileSettingsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return (textView.text as NSString).replacingCharacters(in: range, with: text).count <= 120
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let line = textView.numberOfLine()
        if line <= 4 {
            currentLine = line
            shouldReloadInputUI = currentLine != line
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Bio" {
            textView.text = nil
            textView.textColor = UIColor(named: "#2F385D")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Bio"
            textView.textColor = .lightGray
        }
    }
}
