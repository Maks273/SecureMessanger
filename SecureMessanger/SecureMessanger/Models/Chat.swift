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
    let members: [ChatMember]
    let chat: ChatEntity
}

struct ChatEntity: Codable {
    let id: Int
    let name: String
    let type: Int
    let avatarFileId: Int?
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
    var userIsContact: Bool
    let type: Int
}

extension Chat {
   // static let data: [Chat] = [Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins", members: [], chat: ChatEntity(id: 1, name: "", type: 1, avatarFileId: nil))]
}
