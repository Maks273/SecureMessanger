//
//  String+Extension.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 13.05.2022.
//

import UIKit
import CryptoSwift

extension String {
    func sha256String() -> String? {
        let utfString = self.data(using: .utf8)
        return utfString?.sha256().toHexString()
    }
}
