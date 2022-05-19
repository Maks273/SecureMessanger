//
//  CredentialManager.swift
//
//
//  Created by Maksym Paidych on 05/05/2022.
//

import KeychainAccess

class CredentialManager {
    static let sharedInstance = CredentialManager()
    
    var currentUser: User?
    var userAvatar: UIImage?
   
    
    private let keychain: Keychain

    private let ACCESS_TOKEN = "uk.co.secretChat.access_token"
    private let PRIVATE_RSA = "uk.co.secretChat.private_rsa"
    private let USERNAME = "uk.co.secretChat.username"
    private let NAME = "uk.co.secretChat.name"
    private let PHONE = "uk.co.secretChat.phone"
    private let ID = "uk.co.secretChat.id"

    private init() {
        keychain = Keychain(service: "uk.co.secretChat")
        
    }
    
    func logout() {
        removeDeviceToken()
        self.reset()
//        Intercom.logout()
//        UIApplication.shared.applicationIconBadgeNumber = 0
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            sceneDelegate.loadUI()
//        }
    }
    
    func reset() {
        CredentialManager.sharedInstance.userAvatar = nil
        keychain[ACCESS_TOKEN] = nil
        keychain[USERNAME] = nil
        keychain[PRIVATE_RSA] = nil
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func setAccessToken(token: String) {
        keychain[ACCESS_TOKEN] = token
        
    }

    func getAccessToken() -> String? {
        if let token = keychain[PRIVATE_RSA] {
            return token
            
        } else {
            return nil
            
        }
        
    }
    
    func setRSA(rsa: String) {
        keychain[PRIVATE_RSA] = rsa
        print(keychain[PRIVATE_RSA])
    }
    
    func setId(id: Int) {
        keychain[ID] = String(id)
        
    }

    func getId() -> Int? {
        if let id = keychain[ID] {
            return Int(id)
            
        } else {
            return nil
            
        }
        
    }
    
    func setName(name: String) {
        keychain[NAME] = name
        
    }

    func getName() -> String? {
        if let name = keychain[NAME] {
            return name
            
        } else {
            return nil
            
        }
        
    }
    
    func setPhone(phone: String?) {
        keychain[PHONE] = phone
    }
    

    func getPhone() -> String? {
        if let phone = keychain[PHONE] {
            return phone
        } else {
            return nil
        }
    }
    
    func hasAccessToken() -> Bool {
        if let _ = getAccessToken() {
            return true
            
        } else {
            return false
            
        }
        
    }
    
    func setUsername(username: String) {
        keychain[USERNAME] = username
        
    }
    
    func getUsername() -> String? {
        if let token = keychain[USERNAME] {
            return token
        } else {
            return nil
        
        }
    }
    
    private func removeDeviceToken() {
//        OneXpApi.shared.notificationsDeegister { [weak self] message in
//            UserDefaults.standard.set(nil, forKey: userDefaultTokenKeys.deviceToken)
//            //self?.reset()
//        } failure: { [weak self] error, response in
//            //self?.reset()
//        }
    }
    
}
