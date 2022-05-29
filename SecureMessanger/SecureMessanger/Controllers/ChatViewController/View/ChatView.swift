//
//  ChatView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.03.2022.
//

import UIKit
import SDWebImage

class ChatView: UIView {
    
    @IBOutlet private weak var chatAvatarButton: UIButton!
    @IBOutlet private weak var chatNameLabel: UILabel!
    @IBOutlet weak var chatContainerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var inputContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    var attachMediaAction: (() -> Void)?
    var backAction: (() -> Void)?
    var avatarAction: (() -> Void)?
    var sendAction: ((_ text: String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction private func avatarButtonPressed(_ sender: Any) {
        avatarAction?()
    }
    
    @IBAction private func backButtonPressed(_ sender: Any) {
        backAction?()
    }
   
    @IBAction func sendButtonPressed(_ sender: Any) {
        sendAction?(textView.text)
    }
    
    @IBAction func attachButtonPressed(_ sender: Any) {
        attachMediaAction?()
    }
    
    
    func configureView(with chat: Chat) {
        chatNameLabel.text = chat.chat.name
        avatarImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        avatarImageView.sd_setImage(with: URL(string: chat.chat.avatarURL), placeholderImage: UIImage(systemName: Constants.chatPlaceholderImageName))
    }
    
    func setInputContainerHeight(_ height: CGFloat) {
        inputContainerHeightConstraint.constant = height
    }
}
