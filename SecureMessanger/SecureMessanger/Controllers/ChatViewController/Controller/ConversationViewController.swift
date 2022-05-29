//
//  ConversationViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.05.2022.
//

import UIKit
import MessageKit
import MBProgressHUD
import SDWebImage
import AVKit

 
class ConversationViewController: MessagesViewController {
        
    let outgoingAvatarOverlap: CGFloat = 0
    var chat: Chat?
    var offset = 1
    var nextAvailability: Bool = false
    private var messageList: [DisplayMessage] = []
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    
    private func loadMessages(lastMessageId: Int? = nil, showProgress: Bool = true) {
        guard let chatId = chat?.chat.id else { return }
        var progress: MBProgressHUD?
        
        if showProgress {
            progress = MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        ApiService.shared.fetchMessages(chatId: chatId, lastMessageId: lastMessageId) { [weak self] response, error in
            progress?.hide(animated: true)
            self?.refreshControl.endRefreshing()
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if let response = response {
                lastMessageId == nil ? self.updateMessagesList(result: response.list, lastMessageId: lastMessageId) : self.insetMessagesInList(result: response.list, lastMessageId: lastMessageId)
            }
        }
    }
    
   private func updateMessagesList(result: [Message], lastMessageId: Int?) {
        if lastMessageId == nil {
            self.messageList = []
        }
        self.messageList.append(contentsOf: result.map { DisplayMessage(from: $0) }.reversed())
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
    }
    
    private func insetMessagesInList(result: [Message], lastMessageId: Int?) {
        if lastMessageId == nil {
            messageList = []
        }
        
        messageList.insert(contentsOf: result.map { DisplayMessage(from: $0) }.reversed(), at: 0)
 
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messagesCollectionView.reloadDataAndKeepOffset()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func loadMoreMessages() {
        guard let topMessage = messageList.first else { return }
        loadMessages(lastMessageId: Int(topMessage.messageId), showProgress: false)
    }
    
    private func configureMessageCollectionView() {

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)

        messagesCollectionView.delegate = self
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 45, bottom: 0, right: -18))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 45))
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)))
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 40, height: 40))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 40, height: 40))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 58, right: 0))
        layout?.setMessageOutgoingAccessoryViewPosition(.messageBottom)
        messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)


    }

   
    // MARK: - Helpers
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func insertMessage(_ message: DisplayMessage) {
        messageList.append(message)
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
           // if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
           // }
        })
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] actions in
            guard let self = self else { return nil }
            
            let deleteAction = UIAction(title: "Remove", image: UIImage(systemName: "trash.fill")) { [weak self] action in
                guard let self = self, indexPath.section < self.messageList.count, let messageID = Int(self.messageList[indexPath.section].messageId) else { return }
                self.deleteMessage(id: messageID, at: indexPath.section)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    private func deleteMessage(id: Int, at index: Int) {
        guard let chatId = chat?.chat.id else { return }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.deleteMessage(messageId: id, chatId: chatId) { [weak self] success, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if success == true {
                self.messageList.remove(at: index)
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    private func showUserProfileVC(_ user: User) {
        let vc = ProfileDetailViewController()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showVideoPlayer(for url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    private func showZoomImageVC(image: UIImage) {
        let vc = ZoomImageViewController()
        vc.image = image
        navigationController?.present(vc, animated: true)
    }
    
    


}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {

    // MARK: - Text Messages

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention, .url:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.red]
            }
        default: return MessageLabel.defaultAttributes
        }
    }
    

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }

    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 47/255, green: 56/255, blue: 93/255, alpha: 1) : UIColor(red: 228.0/255.0, green: 228.0/255.0, blue: 228.0/255.0, alpha: 1.0)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        corners.formUnion(.topLeft)
        corners.formUnion(.bottomLeft)
        corners.formUnion(.topRight)
        corners.formUnion(.bottomRight)

        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) || isNextMessageSameSender(at: indexPath) {
            avatarView.isHidden = true
        }else {
            avatarView.backgroundColor = .clear
            avatarView.sd_setImage(with: URL(string: messageList[indexPath.section].user.imageURL ?? ""), placeholderImage: UIImage(named: Constants.userPlacehoderImageName)) { image, error, type, url in
                if image != nil {
                    avatarView.isHidden = false
                    avatarView.image = image
                }
            }
        }
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let photoItem):
            guard let url = photoItem.url else {
                return
            }
            imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imageView.sd_setImage(with: url, placeholderImage: nil)
        case .video(let videoItem):
            guard let url = (videoItem as? ImageMediaItem)?.url  else {
                return
            }
            AVAsset(url: url).generateThumbnail { (image) in
                DispatchQueue.main.async {
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = image
                }
            }
            
        default:
            break
        }
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if !isPreviousMessageSameSender(at: indexPath) {
            return 12.0
        }
        return 0
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

}

extension ConversationViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return ChatUser(from: CredentialManager.sharedInstance.currentUser!)
    }
    func otherUser() -> SenderType {
        return ChatUser(from: CredentialManager.sharedInstance.currentUser!)
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if chat?.chat.type == 2 {
            if !isFromCurrentSender(message: message) && !isPreviousMessageSameSender(at: indexPath) {
                let name = message.sender.displayName
                return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "Arial Hebrew Bold", size: 10)!, NSAttributedString.Key.foregroundColor: UIColor(red: 47/255, green: 56/255, blue: 93/255, alpha: 1)])
            }
        }
        return nil
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let message = messageList[indexPath.section]
        
        guard isFromCurrentSender(message: message) else {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont(name: "Arial Hebrew Bold", size: 10)!, NSAttributedString.Key.foregroundColor: UIColor(red: 47/255, green: 56/255, blue: 93/255, alpha: 1)])
        }
        
        var text: String = ""
        
        if message.recieved {
            text = "✓"
        }
        
        if message.read {
            text = "✓✓"
        }
        
        return NSAttributedString(string: "\(MessageKitDateFormatter.shared.string(from: messageList[indexPath.section].sentDate)) \(text)", attributes: [NSAttributedString.Key.font: UIFont(name: "Arial Hebrew Bold", size: 10)!, NSAttributedString.Key.foregroundColor: UIColor(red: 47/255, green: 56/255, blue: 93/255, alpha: 1)])
    }

}

extension ConversationViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = messageList[indexPath.section]
            showUserProfileVC(message.user.user)
        }
    }

    func didTapImage(in cell: MessageCollectionViewCell) {

        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = messageList[indexPath.section]

            switch message.kind {
            case .video(let videoItem):
                if let videoUrl = videoItem.url {
                    showVideoPlayer(for: videoUrl)
                }
            case .photo(let photoItem):
                let imageView = UIImageView()
                let progress = MBProgressHUD.showAdded(to: view, animated: true)
                imageView.sd_setImage(with: photoItem.url) { [weak self] image, error, _, _ in
                    progress.hide(animated: true)
                    guard let image = image else { return }
                    self?.showZoomImageVC(image: image)
                }
            default:
                break
            }
        }
    }
    
}
