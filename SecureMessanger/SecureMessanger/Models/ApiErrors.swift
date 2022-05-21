//
//  ApiErrors.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.05.2022.
//

import UIKit

struct ApiErrors: Error {
    var message: String
}

extension ApiErrors {
    static var unavailableDecode = ApiErrors(message: "Unable to decode the object")
}

extension ApiErrors: LocalizedError {
    var errorDescription: String? {
        return message.capitalized
    }
}
