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
    
    
    func registerUser(phoneNumber: String) {
        let dict = ["phone": phoneNumber, "deviceInfo": UIDevice.current.identifierForVendor!.uuidString]
        AF.request(baseURL.appending("register/add-device/"), method: .post, parameters: dict, encoder: .json, headers: ["access-token": headerAccessToken]).validate().responseJSON { response in
            print(response)
        }
    }
    
    
}
