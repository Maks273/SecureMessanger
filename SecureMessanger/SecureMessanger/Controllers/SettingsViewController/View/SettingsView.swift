//
//  SettingsView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class SettingsView: UIView {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    
    var logoutAction: (() -> ())?
    var editAction: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        logoutAction?()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        editAction?()
    }
    
    func updateView() {
        usernameLabel.text = CredentialManager.sharedInstance.currentUser?.name
        phoneNumberLabel.text = CredentialManager.sharedInstance.currentUser?.phone
    }
    
}
