//
//  ConfirmPhoneNumberViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit

class ConfirmPhoneNumberViewController: UIViewController {
    
    //MARK: - Varaibles
    
    var phoneNumber: String?
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        turnOnDissmissKeyboardOnViewTap()
        configureView()
        title = "Confirm number"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Private methods
    
    private func configureView() {
        rootView?.numberLabel.text = phoneNumber
        rootView?.nextAction = { [weak self] code in
            guard let self = self else { return }
            self.showProfileSettingsVC()
        }
    }
    
    private func showProfileSettingsVC() {
        let vc = ProfileSettingsViewController()
        vc.phoneNumber = phoneNumber
        navigationController?.pushViewController(vc, animated: true)
    }

}

//MARK: - RootViewGettable

extension ConfirmPhoneNumberViewController: RootViewGettable {
    typealias RootViewType = ConfirmPhoneNumberView
}
