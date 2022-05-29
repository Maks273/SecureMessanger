//
//  URL+Extension.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 28.05.2022.
//

import UIKit
import UniformTypeIdentifiers

extension URL {
    func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}
