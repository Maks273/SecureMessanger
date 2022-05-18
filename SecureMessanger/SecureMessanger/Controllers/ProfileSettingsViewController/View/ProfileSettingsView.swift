//
//  ProfileSettingsView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class ProfileSettingsView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var bioTextView: UITextView!
    @IBOutlet private weak var bioTextViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var avatarButton: UIButton!
    
    //MARK: - Variables
    
    var saveAction: (() -> ())?
    
    //MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
        bioTextView.textColor = bioTextView.text == "Bio" ? .lightGray : UIColor(named: "#2F385D")
    }
    
    //MARK: - IBActions
    
    @IBAction private func saveButtonPressed(_ sender: Any) {
        saveAction?()
    }
    
    //MARK: - Helper
    
    func setupPhoneNumber(_ number: String?) {
        phoneNumberTextField.text = number
    }
    
    func setBioTextViewHeight(_ height: CGFloat) {
        bioTextViewHeight.constant = height
    }
    
    func setName(_ name: String?) {
        usernameTextField.text = name
    }
    
    func setBioInfo(_ text: String?) {
        bioTextView.text = text
    }
    
    func setUserImage(_ imageURL: String?) {
        
    }
    
    func getUserImage() -> UIImage? {
        return avatarButton.imageView?.image
    }
    
    func getUserName() -> String? {
        return usernameTextField.text
    }
    
    func getUserBio() -> String? {
        return bioTextView.text
    }
    
    func getUserPhoneNumber() -> String? {
        return phoneNumberTextField.text
    }
    
    //MARK: - Private methods
    
    
}
