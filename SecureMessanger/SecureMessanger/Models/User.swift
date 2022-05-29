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
            guard let fileId = avatarFileId else { return "" }
            return ApiService.shared.getDownloadFile(fileId: fileId)
        }
    }
    var phone: String
    let id: Int
    let userPublicKey: String?
    var avatarFileId: Int?
    let hash: String
    var description: String
    var isContact: Bool
}
