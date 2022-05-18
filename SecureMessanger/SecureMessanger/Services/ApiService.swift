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
    private let baseURL = "http://rusofobrusofob-001-site1.itempurl.com/api/"
    private let headerAccessToken = "42E04354-282A-46BF-9058-8B10F3714003"
    
    
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
    
    func updateUser(_ user: UpdateUserRequest, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        guard let dict = user.dict else { return }

        let udid = UIDevice.current.identifierForVendor!.uuidString
        
        AF.request(baseURL.appending("\(CredentialManager.sharedInstance.currentUser!.hash)/\(udid.sha256())/user/update"), method: .post, parameters: dict, encoding: JSONEncoding.default, headers: ["access-token": headerAccessToken]).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                print(result)
                completion(true, nil)
            case .failure(let error):
                var newError: Error?
                if let data = response.data, let message = String(data: data, encoding: .utf8) {
                    newError = ApiErrors(message: message)
                }
                completion(false, newError != nil ? newError : error.underlyingError)
            }
        }
    }
    
}
