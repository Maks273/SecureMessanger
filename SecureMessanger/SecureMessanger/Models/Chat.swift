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
    let name: String
    let imageURL: String
}

extension User {
    static let vladimir = User(name: "Vladimir Zelenskij", imageURL: "https://uk.wikipedia.org/wiki/Стів_Джобс#/media/Файл:Steve_Jobs_Headshot_2010-CROP.jpg")
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
