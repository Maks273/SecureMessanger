//
//  ConfirmPhoneNumberViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit
import MBProgressHUD
import SwiftyRSA

class ConfirmPhoneNumberViewController: UIViewController {
    
    //MARK: - Varaibles
    
    var phoneNumber: String?
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        turnOnDissmissKeyboardOnViewTap()
        configureView()
        title = "Confirm number"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Private methods
    
    private func configureView() {
        rootView?.numberLabel.text = phoneNumber
        rootView?.nextAction = { [weak self] code in
            guard let self = self else { return }
            self.approvePhoneNumber()
        }
        
        rootView?.resendCodeAction = { [weak self] in
            self?.resendCode()
        }
    }
    
    private func showProfileSettingsVC() {
        let vc = ProfileSettingsViewController()
        vc.phoneNumber = phoneNumber
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showMainVC() {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController = MainTabBarViewController()
        sceneDelegate?.window?.makeKeyAndVisible()
    }
    
    private func resendCode() {
        guard let phoneNumber = phoneNumber else { return }

        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        ApiService.shared.resendCode(phoneNumber: phoneNumber) { [weak self] success in
            progress.hide(animated: true)
            guard let self = self else { return }
            self.showAlert(title: success ? "Success" : "Error", message: success ? "Successfuly resent the code" : "Error with resending the code(retry in a 30 seconds)", okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
        }
    }

    private func approvePhoneNumber() {
        
        var publicKey: String?
        var privateKey: String?
        
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 1024)
            privateKey = try keyPair.privateKey.pemString()
            publicKey = try keyPair.publicKey.pemString()
        } catch (let error) {
            print(error.localizedDescription)
        }
        
        guard let publicKey = publicKey, let privateKey = privateKey else { return }
        //CredentialManager.sharedInstance.setRSA(rsa: publicKey)
        
        self.sendApprovePhoneNumber(secret: publicKey, privateKey: privateKey)

    }
    
    private func sendApprovePhoneNumber(secret: String, privateKey: String) {
        guard let phoneNumber = phoneNumber, let codeString = rootView?.approveCode(), let code = Int(codeString) else { return }

        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        ApiService.shared.approveCode(phoneNumber: phoneNumber, code: code, secret: secret) { [weak self] user, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if let user = user {
                CredentialManager.sharedInstance.currentUser = user
                self.savePrivateKey(privateKey: privateKey)
            }
        }
       
    }
    
    private func savePrivateKey(privateKey: String) {
        showAlert(title: "Private key", message: "Do you already have private key? (Press, save if you aren't an user of the app)", okTitle: "Save", cancelTitle: "Yes") { [weak self] _ in
            self?.processSaving(key: privateKey)
        } cancelAction: { [weak self] _ in
            self?.checkoutPrivatekey()
        }

    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func processSaving(key: String) {
        let filename = getDocumentsDirectory().appendingPathComponent(UUID().uuidString)

        do {
            try key.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            if FileManager.default.fileExists(atPath: filename.path) {
                let url = URL(fileURLWithPath: filename.path)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.completionWithItemsHandler = { (activityType, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    self.checkoutPrivatekey()
                 }
                self.present(activityViewController, animated: true, completion: nil)
            }
            else {
                debugPrint("document was not found")
            }
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    private func checkoutPrivatekey() {
        showAlert(title: "Private key checkout", message: "Please, upload your private key to open the app", okTitle: "Ok", cancelTitle: "Cancel") { [weak self] _ in
            self?.showDocumentPicker()
        } cancelAction: { _ in
            
        }

    }
    
    private func showDocumentPicker() {
        let importMenu = UIDocumentPickerViewController(documentTypes: [String("public.data")], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .automatic
        self.present(importMenu, animated: true, completion: nil)
    }
}

//MARK: - RootViewGettable

extension ConfirmPhoneNumberViewController: RootViewGettable {
    typealias RootViewType = ConfirmPhoneNumberView
}


extension ConfirmPhoneNumberViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            do {
                let privateStringKey = try String(contentsOf: url)
                guard let publicKeyString = CredentialManager.sharedInstance.currentUser?.userPublicKey else { return }
                
                do {
                    let publicKey = try PublicKey(pemEncoded: publicKeyString)
                    let privateKey = try PrivateKey(pemEncoded: privateStringKey)
                    
                    let randomString = UUID().uuidString
                    let clearMessage = try ClearMessage(string: randomString, using: .utf8)
                    
                    let encrypted = try clearMessage.encrypted(with: publicKey, padding: .PKCS1)
                    let decrypted = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
                    
                    let decriptedString = try decrypted.string(encoding: .utf8)
                    
                    guard randomString == decriptedString else {
                        showAlert(title: "Error", message: "Wrong private key", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
                        return
                    }
                    CredentialManager.sharedInstance.setRSA(rsa: privateStringKey)
                    CredentialManager.sharedInstance.setPhone(phone: CredentialManager.sharedInstance.currentUser?.phone)
                    CredentialManager.sharedInstance.currentUser?.name?.isEmpty == true ? showProfileSettingsVC() : showMainVC()
                    
                } catch {
                    showAlert(title: "Error", message: "Wrong private key", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }
                
            } catch {
                showAlert(title: "Error", message: "Unable to read the file", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }
        }
    }
    
    
}
