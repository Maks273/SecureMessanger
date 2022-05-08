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
