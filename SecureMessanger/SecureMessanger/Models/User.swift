//
//  User.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 08.05.2022.
//

import UIKit

struct RegisterUser: Codable {
    let phone: String
    let name: String
    let description: String
    let deviceInfo: String
}

struct ConstactsResponse: Codable {
    let totalPages: Int
    let items: [User]
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
    var isContact: Bool
}
