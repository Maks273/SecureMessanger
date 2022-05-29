//
//  UploadFileRequest.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 28.05.2022.
//

import Foundation

struct UploadFileRequest: Codable {
    let mime: String
    let name: String
    let base64: String?
}

struct File: Codable {
    let id: Int
}
