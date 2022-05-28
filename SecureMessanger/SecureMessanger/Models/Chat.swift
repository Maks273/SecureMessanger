//
//  Chat.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

struct Chat: Codable {
    let user: User?
    let lastMessage: LastMessage?
    var members: [ChatMember]
    let chat: ChatEntity
}

struct ChatEntity: Codable {
    let id: Int
    var name: String
    let type: Int
    var avatarFileId: Int?
    let unreadCount: Int
    let unrecievedCount: Int
    
    var avatarURL: String? {
        return avatarFileId == nil ? nil : ""
    }
    
}

struct LastMessage: Codable {
    let id: Int
    let chatId: Int
    let fromUserId: Int
    let type: Int
    let fileId: Int?
    let referenceId: Int?
    let timeStamp: Int
    let message: String
    let fromUserName: String
    let fromUserAvatarFileId: Int?
}

struct ChatMember: Codable {
    let userId: Int
    let fromUserId: Int
    let userName: String
    let userHash: String
    let userPhone: String
    let userPublicKey: String
    let userDescription: String?
    let userAvatarFileId: Int?
    var userIsContact: Bool
    let type: Int
    
    var avatarURL: String {
        return ""
    }
}
