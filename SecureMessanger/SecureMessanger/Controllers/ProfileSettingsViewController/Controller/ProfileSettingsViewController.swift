//
//  ProfileSettingsViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

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
    
    //MARK: - Private methods
    
    private func configureView() {
        rootView?.setupPhoneNumber(phoneNumber)
        rootView?.saveAction = { [weak self] in
            guard let self = self else { return }
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = MainTabBarViewController()
            sceneDelegate?.window?.makeKeyAndVisible()
        }
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
