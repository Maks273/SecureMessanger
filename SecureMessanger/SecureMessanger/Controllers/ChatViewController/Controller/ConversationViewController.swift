//
//  ConversationViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.05.2022.
//

import UIKit
import MessageKit
import MBProgressHUD
 
class ConversationViewController: MessagesViewController {
        
    let outgoingAvatarOverlap: CGFloat = 0
    var chatId: Int?
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
    
    func loadMessages(lastMessageId: Int? = nil, showProgress: Bool = true) {
        guard let chatId = chatId else { return }
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
    
    func updateMessagesList(result: [Message], lastMessageId: Int?) {
        if lastMessageId == nil {
            self.messageList = []
        }
        self.messageList.append(contentsOf: result.map { DisplayMessage(from: $0) }.reversed())
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
    }
    
    func insetMessagesInList(result: [Message], lastMessageId: Int?) {
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
    
    func refreshLatestMessages() {
        
    }
    
    
    @objc func loadMoreMessages() {
        guard let topMessage = messageList.first else { return }
        loadMessages(lastMessageId: Int(topMessage.messageId), showProgress: false)
    }
    
    func configureMessageCollectionView() {

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
        return true
       // messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return true
        //messageList[indexPath.section].user == messageList[indexPath.section + 1].user
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
    
    
    // MARK: - MessagesDataSource

    

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
        return isFromCurrentSender(message: message) ? .red : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
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
        avatarView.isHidden = true
        //avatarView.isHidden = isNextMessageSameSender(at: indexPath)
       // avatarView.setImageForName(message.sender.displayName, circular: true, textAttributes: nil)
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
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
        let name = message.sender.displayName
        
        return nil
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
       
        return nil
    }

}

extension ConversationViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        
    }

    func didTapImage(in cell: MessageCollectionViewCell) {
        
    }
    
}
