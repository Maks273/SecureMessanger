//
//  ChatViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.03.2022.
//

import UIKit
import MBProgressHUD
import CryptoSwift
import SwiftyRSA

class ChatViewController: UIViewController {
    
    var chat: Chat?
    private var conversationViewController: ConversationViewController? = ConversationViewController()
    private var initialHeight: CGFloat!
    private var currentLine = 1
    private var shouldReloadInputUI: Bool = false {
        didSet {
            let height: CGFloat = 60 + (currentLine == 1 ? 0 : CGFloat(currentLine * 8))
            rootView?.setInputContainerHeight(height)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureMessagesVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        fetchChat()
        fillData()
        initialHeight = view.frame.size.height
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }


    private func setupView() {
        rootView?.backAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        rootView?.avatarAction = {
            
        }
        
        rootView?.sendAction = { [weak self] message in
            self?.sendMessage(text: message)
        }
        
    }
    
    private func fetchChat() {
        guard let id = chat?.chat.id else { return }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        ApiService.shared.fetchChat(id: id) { [weak self] chat, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else if let chat = chat {
                self.chat = chat
                self.fillData()
            }
        }
    }
    
    private func fillData() {
        guard let chat = chat else { return }
        rootView?.configureView(with: chat)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let _ = view.convert(keyboardScreenEndFrame, from: view.window)

        
        if notification.name == UIResponder.keyboardWillHideNotification {
            view.frame.size.height = initialHeight
        } else {
            view.frame.size.height = initialHeight
            view.frame.size.height -= keyboardScreenEndFrame.size.height
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    private func configureMessagesVC() {
        guard let conversationViewController = conversationViewController else {
            fatalError("ConversationMessagesViewController is nil")
            return
        }
       
        conversationViewController.chatId = chat?.chat.id
        conversationViewController.willMove(toParent: self)
        addChild(conversationViewController)
        conversationViewController.view.frame.size = rootView!.chatContainerView.frame.size
        rootView?.chatContainerView.addSubview(conversationViewController.view)
        conversationViewController.didMove(toParent: self)
        
    }
    
    private func sendMessage(text: String?) {
        guard let text = text, !text.isEmpty, let chatID = chat?.chat.id, var members = chat?.members else { return }

        
        let messageEntity = CreateMessageEntity(chatId: chatID, fileId: nil)
        var bodies: [CreateMessageBody] = []
        
        let randomString = String.randomAlphaNumericString(length: 8)
        
        let md5 = randomString.data(using: .utf8)
        let sha = randomString.data(using: .utf8)
        let newMD = md5?.md5()
        let newSHA = sha?.sha256()
        
        
        do {

            let aes = try AES(key: newSHA!.bytes, blockMode: CBC(iv: newMD!.bytes), padding: .pkcs7)
            let encrypted = try aes.encrypt(text.data(using: .utf8)!.bytes)
            let encryptedMessage = encrypted.toHexString()
          
            members.forEach { member in
                do {
                    let publicKey = try PublicKey(pemEncoded: member.userPublicKey)
                    let clearMessage = try ClearMessage(string: randomString, using: .utf8)
                    
                    let encrypted = try clearMessage.encrypted(with: publicKey, padding: .PKCS1)
                    
                    let encryptedMessageObject = CreateMessageEncrypted(key: encrypted.base64String, value: encryptedMessage)
                    
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(encryptedMessageObject)
                    guard let json = String(data: jsonData, encoding: .utf8) else { return }
                    
                    let body = CreateMessageBody(toUserId: member.userId, message: json)
                    bodies.append(body)
                    
                    
                } catch(let error) {
                    print(error.localizedDescription)
                }
            }
            
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        let requestModel = CreateMessageRequest(message: messageEntity, bodies: bodies)
        
        processingSendMessage(model: requestModel)
        
    }
    
    private func processingSendMessage(model: CreateMessageRequest) {
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        ApiService.shared.sendMessage(model: model) { [weak self] message, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else if let message = message {
                self.conversationViewController?.insertMessage(DisplayMessage(from: message))
            }
            
            self.rootView?.textView.text = nil
            self.rootView?.textView.resignFirstResponder()
            self.rootView?.textView.endEditing(true)
        }
    }

}

extension ChatViewController: RootViewGettable {
    typealias RootViewType = ChatView
}

extension ChatViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return (textView.text as NSString).replacingCharacters(in: range, with: text).count <= 120
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let line = textView.numberOfLine()
        if line <= 4 {
            currentLine = line
            shouldReloadInputUI = currentLine != line
        }
    }
}
