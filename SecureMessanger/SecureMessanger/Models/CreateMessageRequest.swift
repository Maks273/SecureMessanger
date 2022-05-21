//
//  CreateMessageRequest.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.05.2022.
//

import Foundation

struct CreateMessageRequest: Codable {
    var message: CreateMessageEntity
    var bodies: [CreateMessageBody]
}

struct CreateMessageEntity: Codable {
    let chatId: Int
    let type: Int = 1
    let fileId: Int?
}

struct CreateMessageBody: Codable {
    let toUserId: Int
    let message: String
}

struct CreateMessageEncrypted: Codable {
    let key: String
    let value: String
}
