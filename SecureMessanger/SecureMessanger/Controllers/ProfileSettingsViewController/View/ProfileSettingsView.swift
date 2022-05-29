//
//  ProfileSettingsView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit
import SDWebImage

class ProfileSettingsView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var bioTextView: UITextView!
    @IBOutlet private weak var bioTextViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var avatarButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //MARK: - Variables
    
    var saveAction: (() -> ())?
    var avatarAction: (() -> ())?
    
    //MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
        bioTextView.textColor = bioTextView.text == "Bio" ? .lightGray : UIColor(named: "#2F385D")
    }
    
    //MARK: - IBActions
    
    @IBAction private func saveButtonPressed(_ sender: Any) {
        saveAction?()
    }
    
    @IBAction private func avatarButtonPressed(_ sender: Any) {
        avatarAction?()
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
        avatarImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatarImageView.sd_setImage(with: URL(string: imageURL ?? ""), placeholderImage: UIImage(named: Constants.userPlacehoderImageName))
    }
    
    func getUserImage() -> UIImage? {
        return avatarImageView.image
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
