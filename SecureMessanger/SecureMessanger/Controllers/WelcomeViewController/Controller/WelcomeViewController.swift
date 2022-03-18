//
//  WelcomeViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    //MARK: - Private methods
    
    private func configureView() {
        rootView?.configure()
        
        rootView?.loginAction = { [weak self] in
            
        }
        rootView?.signUpAction = { [weak self] in
            
        }
    }
    
    
}

//MARK: - RootViewGettable
extension WelcomeViewController: RootViewGettable {
    typealias RootViewType = WelcomeView
}

// MARK: - UITextViewDelegate
extension WelcomeViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
