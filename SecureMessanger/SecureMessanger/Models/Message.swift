//
//  Message.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.05.2022.
//

import UIKit
import MessageKit
import SwiftyRSA
import CryptoSwift

struct Message: Codable {
    let id: Int
    let chatId: Int
    let type: Int
    let message: String?
    let fromUserName: String
    let timeStamp: Int
    let fileId: Int?
    let fromUserAvatarFileId: Int?
    let fromUserId: Int
    let fromUserPhone: String
    var fromUserIsContact: Bool
    let read: Bool
    let recieved: Bool
    
    let mediaType: String?
    
    var fileURL: URL? {
        return URL(string: "")
    }
}

struct MessagesResponse: Codable {
    let isEnd: Bool
    let list: [Message]
}

enum MediaType: String {
    case video = "video"
    case photo = "photo"
    case document = "document"
}

struct DisplayMessage: MessageType {
    var sender: SenderType {
        return user
    }
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var user: ChatUser
    var message: String?
    let read: Bool
    let recieved: Bool
    
    private init(kind: MessageKind, message: Message) {
        self.kind = kind
        self.user = ChatUser(from: User(name: message.fromUserName, phone: message.fromUserPhone, id: message.fromUserId, userPublicKey: nil, avatartFileId: message.fromUserAvatarFileId, hash: "", description: "", isContact: message.fromUserIsContact))
        self.messageId = "\(message.id)"
        self.sentDate = message.timeStamp.dateFromTimestamp()
        self.message = message.message?.decodeMessage()
        self.read = message.read
        self.recieved = message.recieved
        switch kind {
        case .text(let string):
            self.kind = .text(self.message ?? "")
        default: break
        }
    }
    
    init(from message: Message) {
        if let url = message.fileURL {
            self.init(url: url, message: message)
        } else {
            self.init(kind: .text(message.message ?? ""), message: message)
        }
    }
    
    init(url: URL, message: Message) {
        let mediaItem = ImageMediaItem(imageURL: url, thubmURL: URL(string: ""))
        var kind = MessageKind.photo(mediaItem)
        if message.mediaType?.lowercased() == "video" {
            kind = MessageKind.video(mediaItem)
        } else if message.mediaType?.lowercased() == "document" {
            kind = MessageKind.custom(mediaItem.url)
        }
        self.init(kind: kind, message: message)
        self.user = ChatUser(from: User(name: message.fromUserName, phone: message.fromUserPhone, id: message.fromUserId, userPublicKey: nil, avatartFileId: message.fromUserAvatarFileId, hash: "", description: "", isContact: message.fromUserIsContact))
        self.messageId = "\(message.id)"
        self.sentDate = message.timeStamp.dateFromTimestamp()
        self.message = message.message?.decodeMessage()
    }
}

struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    var thumbURL: URL?

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

    init(imageURL: URL, thubmURL: URL?) {
        self.url = imageURL
        self.thumbURL = thubmURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}

struct ChatUser: SenderType, Equatable {
    static func == (lhs: ChatUser, rhs: ChatUser) -> Bool {
        return lhs.senderId == rhs.senderId
    }
    
    var senderId: String
    var displayName: String
    var isMy: Bool = false
    var imageURL: String?
    
    var user: User
    
    init(from user: User) {
        self.user = user
        self.senderId = "\(user.id)"
        self.displayName = user.name  ?? "No name"
        self.imageURL = user.avatarUrl
        self.isMy = user.id == CredentialManager.sharedInstance.currentUser?.id
    }
    
}
