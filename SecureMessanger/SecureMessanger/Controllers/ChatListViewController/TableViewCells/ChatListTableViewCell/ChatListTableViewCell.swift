//
//  ChatListTableViewCell.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit
import SDWebImage

class ChatListTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var unreadView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var shortNameLabel: UILabel!
    
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
        usernameLabel.text = model.chat.name //: model.lastMessage?.fromUserName == nil ? model.chat.name : model.lastMessage?.fromUserName
        messageLabel.text = model.lastMessage?.message.decodeMessage()
        timeLabel.text = model.lastMessage?.timeStamp.dateStringFromTimestamp(with: .hhmm)
        //configureShortNameLabel(model: model)
        avatarImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatarImageView.sd_setImage(with: URL(string: model.chat.avatarURL ?? ""), placeholderImage: UIImage(systemName: "message.fill"))
        unreadView.isHidden = model.chat.unreadCount < 1
    }
    
    
    private func configureShortNameLabel(model: Chat) {
        var shortName: String = ""
        model.chat.name.forEach { char in
            if shortName.count < 2 {
                shortName.append(char)
            } else {
                return
            }
        }
        shortNameLabel.text = shortName
        shortNameLabel.isHidden = model.chat.avatarFileId != nil
    }
}
