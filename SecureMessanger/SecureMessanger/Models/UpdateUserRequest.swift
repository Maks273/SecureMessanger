//
//  UpdateUserRequest.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.05.2022.
//

import Foundation

struct UpdateUserRequest: Codable {
    var name: String?
    var phone: String?
    var description: String?
}
