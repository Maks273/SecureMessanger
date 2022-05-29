//
//  String+Extension.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 13.05.2022.
//

import UIKit
import CryptoSwift
import SwiftyRSA
import MobileCoreServices

extension String {
    func sha256String() -> String? {
        let utfString = self.data(using: .utf8)
        return utfString?.sha256().toHexString()
    }
    
    static func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0 ..< length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    func convertStringToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func decodeMessage() -> String? {
        guard let userPrivateKey = CredentialManager.sharedInstance.getAccessToken(),
                let dict = self.convertStringToDictionary(),
                let key = dict["key"] as? String,
                let value = dict["value"] as? String else { return nil }
        
        
        do {
            
            let privateKey = try PrivateKey(pemEncoded: userPrivateKey)
            
            let encryptedKey = try EncryptedMessage(base64Encoded: key)
            
            let decryptedKey = try encryptedKey.decrypted(with: privateKey, padding: .PKCS1)
            
            let decryptedKeyString = try decryptedKey.string(encoding: .utf8)
            
            let md5 = decryptedKeyString.data(using: .utf8)
            let sha = decryptedKeyString.data(using: .utf8)
            let newMD = md5?.md5()
            let newSHA = sha?.sha256()
            
            
            let aes = try AES(key: newSHA!.bytes, blockMode: CBC(iv: newMD!.bytes), padding: .pkcs7)
            let decryptedMessage = try aes.decrypt(Array<UInt8>(hex: value))
            let decryptedData = Data(decryptedMessage)
            return String(data: decryptedData, encoding: .utf8)
            
        } catch (let error) {
            print(error.localizedDescription)
        }

        return nil
    }
    
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
    
    func isVideoMime() -> Bool {
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }
}
