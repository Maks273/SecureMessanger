//
//  LoginView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import FlagPhoneNumber
import UIKit

class LoginView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var phoneTextField: FPNTextField!
    
    //MARK: - Variables
    
    var nextAction: (() -> ())?
    
    
    //MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        phoneTextField.setFlag(countryCode: .UA)
    }
    
    //MARK: - IBActions
    
    
    @IBAction private func nextButtonPressed(_ sender: Any) {
        nextAction?()
    }
    
    //MARK: - Helper
    
    func phoneNumber() -> String? {
        return phoneTextField.text
    }
    
    
}
