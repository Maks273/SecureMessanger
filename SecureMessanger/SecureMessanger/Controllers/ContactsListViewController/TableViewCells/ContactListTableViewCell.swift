//
//  ContactListTableViewCell.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit
import SDWebImage

class ContactListTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    
    //MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Helper
    
    func configure(with model: User) {
        usernameLabel.text = model.name
        avatarImageView.sd_setImage(with: URL(string: model.avatarUrl), placeholderImage: UIImage(named: Constants.userPlacehoderImageName))
    }
    
    func configure(with chatMember: ChatMember) {
        usernameLabel.text = chatMember.userName
        avatarImageView.sd_setImage(with: URL(string: chatMember.avatarURL), placeholderImage: UIImage(named: Constants.userPlacehoderImageName))
    }
    
}
