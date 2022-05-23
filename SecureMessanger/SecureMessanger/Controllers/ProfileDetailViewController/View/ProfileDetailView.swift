//
//  ProfileDetailView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.05.2022.
//

import UIKit
import SDWebImage

class ProfileDetailView: UIView {
    
    @IBOutlet private weak var avatarButton: UIButton!
    @IBOutlet private weak var phoneNumber: UITextField!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var connectButton: UIButton!
    @IBOutlet private weak var messageButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    var messageAction: (() -> Void)?
    var connectAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction private func messageButtonPressed(_ sender: Any) {
        messageAction?()
    }
    
    @IBAction private func connectButtonPressed(_ sender: Any) {
        connectAction?()
    }
    
    
    func configure(model: User) {
        nameLabel.text = model.name
        phoneNumber.text = model.phone
        descriptionLabel.text = model.description
        connectButton.isHidden = model.id == CredentialManager.sharedInstance.currentUser?.id
        messageButton.isHidden = model.id == CredentialManager.sharedInstance.currentUser?.id
        avatarButton.sd_setImage(with: URL(string: model.avatarUrl), for: .normal, placeholderImage: UIImage(named: Constants.userPlacehoderImageName))
    }
    
    func setConnectButtonTitle(_ title: String) {
        connectButton.setTitle(title, for: .normal)
    }
}
