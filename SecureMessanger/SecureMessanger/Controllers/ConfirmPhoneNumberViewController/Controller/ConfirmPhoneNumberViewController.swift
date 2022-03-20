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
        rootView?.numberLabel.text = phoneNumber
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}

//MARK: - RootViewGettable

extension ConfirmPhoneNumberViewController: RootViewGettable {
    typealias RootViewType = ConfirmPhoneNumberView
}
