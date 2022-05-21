//
//  ApiService.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 08.05.2022.
//

import Foundation
import Alamofire

class ApiService {
    
    private init() {}
    
    static let shared = ApiService()
    private let baseURL = "http://superchathost-001-site1.dtempurl.com/api/"
    private let headerAccessToken = "42E04354-282A-46BF-9058-8B10F3714003"
    private let privateHeaderAccessToken = "28899969-D3C6-46BB-83C7-AA6338FDB572"
    
    
    func registerUser(phoneNumber: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let dict = ["phone": phoneNumber, "deviceInfo": UIDevice.current.identifierForVendor!.uuidString]
        AF.request(baseURL.appending("register/"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": headerAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                completion(nil, error.underlyingError)
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any], let user = try? DictionaryDecoder.shared.decode(User.self, from: data)  {
                    completion(user, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }

            }
        }
    }
    
    func resendCode(phoneNumber: String, completion: @escaping (_ success: Bool) -> Void) {
        let udid = UIDevice.current.identifierForVendor!.uuidString
        let dict = ["phone": phoneNumber, "deviceInfoHash": udid.sha256()]
        AF.request(baseURL.appending("register/resend-approve-code/"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": headerAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? Bool, data {
                    completion(true)
                }else {
                    completion(false)
                }
            case .failure(let _):
                completion(false)
            }
        }
    }
    
    
    func approveCode(phoneNumber: String, code: Int, secret: String, completion: @escaping (_ success: User?, _ error: Error?) -> Void) {
        let udid = UIDevice.current.identifierForVendor!.uuidString
        let dict = ["phone": phoneNumber, "deviceInfoHash": udid.sha256(), "code": code, "userPublicKey": secret] as [String : Any]
        AF.request(baseURL.appending("register/approve/"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": headerAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let user = try? DictionaryDecoder.shared.decode(User.self, from: data)
                    completion(user, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
    func updateUser(_ user: UpdateUserRequest, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        guard let dict = user.dict else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString
        
        AF.request(baseURL.appending("\(CredentialManager.sharedInstance.currentUser!.hash)/\(udid.sha256())/user/update"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let user = try? DictionaryDecoder.shared.decode(User.self, from: data)
                    completion(user, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
    func fetchUser(phone: String, deviceInfo: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let dict = ["phone": phone, "deviceInfoHash": deviceInfo.sha256()]
        
        AF.request(baseURL.appending("register/get-user"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": headerAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let user = try? DictionaryDecoder.shared.decode(User.self, from: data)
                    completion(user, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
    func fetchChats(completion: @escaping (_ chats: [Chat], _ error: Error?) -> Void) {
        guard let hash = CredentialManager.sharedInstance.currentUser?.hash else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString.sha256()
        
        AF.request(baseURL.appending("\(hash)/\(udid)/chat/get-chats-screen"), method: .get, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [[String: Any]] {
                    let chats = data.compactMap { try? DictionaryDecoder.shared.decode(Chat.self, from: $0) }
                    completion(chats, nil)
                }else {
                    completion([], ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion([], newError != nil ? newError : error.underlyingError)
            }
        }
        
    }
    
    func searchMember(phoneNumber: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        guard let hash = CredentialManager.sharedInstance.currentUser?.hash else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString.sha256()
        let dict = ["phone": phoneNumber]
        
        AF.request(baseURL.appending("\(hash)/\(udid)/user/find-by-phone"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let user = try? DictionaryDecoder.shared.decode(User.self, from: data)
                    completion(user, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
    func createChat(model: CreateChatRequest, completion: @escaping (_ chat: Chat?, _ error: Error?) -> Void) {
        
        guard let hash = CredentialManager.sharedInstance.currentUser?.hash else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString.sha256()
        
        let dict = model.dict
        
        AF.request(baseURL.appending("\(hash)/\(udid)/chat/add"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let chat = try? DictionaryDecoder.shared.decode(Chat.self, from: data)
                    completion(chat, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
    func fetchChat(id: Int, completion: @escaping (_ chat: Chat?, _ error: Error?) -> Void) {
        guard let hash = CredentialManager.sharedInstance.currentUser?.hash else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString.sha256()
        
        AF.request(baseURL.appending("\(hash)/\(udid)/chat/\(id)"), method: .get, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let chat = try? DictionaryDecoder.shared.decode(Chat.self, from: data)
                    completion(chat, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    
    }
    
    func sendMessage(model: CreateMessageRequest, completion: @escaping (_ message: Message?, _ error: Error?) -> Void) {
        guard let hash = CredentialManager.sharedInstance.currentUser?.hash else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString.sha256()
        
        let dict = model.dict
        
        AF.request(baseURL.appending("\(hash)/\(udid)/chat/message/add"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let message = try? DictionaryDecoder.shared.decode(Message.self, from: data)
                    completion(message, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
    func fetchMessages(chatId: Int, lastMessageId: Int?, completion: @escaping (_ message: MessagesResponse?, _ error: Error?) -> Void) {
        guard let hash = CredentialManager.sharedInstance.currentUser?.hash else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString.sha256()
        
        let dict = ["pageSize": 2, "chatId": chatId, "order": 2, "lastMessageId": lastMessageId]
        
        AF.request(baseURL.appending("\(hash)/\(udid)/chat/message/load"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                print("")
                if let dict = result as? [String: Any], let data = dict["data"] as? [String: Any] {
                    let message = try? DictionaryDecoder.shared.decode(MessagesResponse.self, from: data)
                    completion(message, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
    func deleteChat(chatId: Int, completion: @escaping (_ success: Bool?, _ error: Error?) -> Void) {
        guard let hash = CredentialManager.sharedInstance.currentUser?.hash else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString.sha256()

        
        AF.request(baseURL.appending("\(hash)/\(udid)/chat/\(chatId)"), method: .delete, headers: ["access-token": privateHeaderAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                if let dict = result as? [String: Any], let data = dict["data"] as? Bool {
                    completion(data, nil)
                }else {
                    completion(nil, ApiErrors.unavailableDecode)
                }
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(nil, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
}
