//
//  ProfileDetailView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.05.2022.
//

import UIKit

class ProfileDetailView: UIView {
    
    @IBOutlet private weak var avatarButton: UIButton!
    @IBOutlet private weak var phoneNumber: UITextField!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var connectButton: UIButton!
    
    var messageAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func messageButtonPressed(_ sender: Any) {
        messageAction?()
    }
    
    @IBAction func connectButtonPressed(_ sender: Any) {
    
    }
    
    
    func configure(model: User) {
        nameLabel.text = model.name
        phoneNumber.text = model.phone
    }
}
