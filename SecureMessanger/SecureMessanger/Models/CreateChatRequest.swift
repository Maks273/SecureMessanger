//
//  CreateChatRequest.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 19.05.2022.
//

import UIKit

struct CreateChatRequest: Codable {
    var chat: CreateCharEntity
    var members: [CreateChatMemberEntity]
}

struct CreateCharEntity: Codable {
    var name: String?
    var type: Int
}

struct CreateChatMemberEntity: Codable {
    var type: Int
    var fromUserId: Int
    var userId: Int
}
