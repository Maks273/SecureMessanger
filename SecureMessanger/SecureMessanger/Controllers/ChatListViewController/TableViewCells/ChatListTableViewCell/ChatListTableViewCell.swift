//
//  ChatListTableViewCell.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var unreadView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    //MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //MARK: - Helper
    
    func configure(with model: Chat) {
        unreadView.isHidden = true
        let isGroup = model.chat.type == 2
        usernameLabel.text = isGroup ? model.chat.name : model.lastMessage?.fromUserName == nil ? model.chat.name : model.lastMessage?.fromUserName
        messageLabel.text = model.lastMessage?.message
        timeLabel.text = model.lastMessage?.timeStamp.dateStringFromTimestamp(with: .hhmm)
    }
}
