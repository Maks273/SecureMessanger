//
//  Chat.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

struct Chat: Codable {
    let user: User
    let lastMessage: String
    let isUnread: Bool
    let time: String
}

struct User: Codable {
    var name: String?
    var avatarUrl: String {
        get {
            return "https://uk.wikipedia.org/wiki/Стів_Джобс#/media/Файл:Steve_Jobs_Headshot_2010-CROP.jpg"
        }
    }
    var phone: String
    let id: Int
    let userPublicKey: String?
    let avatartFileId: Int?
    let hash: String
    var description: String
}

extension User {
    static let vladimir = User(name: "Vladimir Zelenskij", phone: "", id: 2, userPublicKey: "", avatartFileId: 2, hash: "", description: "")
    static let data: [User] = [vladimir, vladimir, vladimir, vladimir, vladimir, vladimir, vladimir, vladimir, vladimir, vladimir, vladimir, vladimir, vladimir]
}

extension Chat {
    static let data: [Chat] = [Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: false, time: "15 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "335 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins"),
                               Chat(user: User.vladimir, lastMessage: "Hey Maks. Hope you are going well. We have won the war!", isUnread: true, time: "5 mins")
    ]
}
