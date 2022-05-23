//
//  MemberTableViewCell.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 19.05.2022.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(model: User) {
        nameLabel.text = model.name
        avatarImageView.sd_setImage(with: URL(string: model.avatarUrl), placeholderImage: UIImage(named: Constants.userPlacehoderImageName))
    }
    
}
