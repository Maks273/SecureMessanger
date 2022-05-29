//
//  ProfileSettingsViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit
import MBProgressHUD
import Swime

class ProfileSettingsViewController: UIViewController {
    
    //MARK: - Variabels
    
    var phoneNumber: String?
    private let bioCharLimit = 120
    private var currentLine = 1
    private var shouldReloadInputUI: Bool = false {
        didSet {
            let height: CGFloat = 40 + (currentLine == 1 ? 0 : CGFloat(currentLine * 8))
            rootView?.setBioTextViewHeight(height)
        }
    }
    private var selectedImage: UIImage?
    private var selectedImageURL: URL?
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        configureView()
        title = "Profile settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
        fillData()
    }
    
    //MARK: - Private methods
    
    private func configureView() {
        rootView?.setupPhoneNumber(phoneNumber)
        rootView?.saveAction = { [weak self] in
            guard let self = self else { return }
            self.updateUser()
        }
        
        rootView?.avatarAction = { [weak self] in
            guard let self = self else { return }
            self.showPickMedia()
        }
    }
    
    private func updateUser() {
        
        let username = rootView?.getUserName()
        let bio = rootView?.getUserBio()
        let image = rootView?.getUserImage()
        
        guard username?.isEmpty == false else  {
            showAlert(title: "Warning", message: "The username can't be empty", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }

        handleUpdateUser(model: UpdateUserRequest(name: username, description: bio, avatarFileId: CredentialManager.sharedInstance.currentUser?.avatarFileId))
        
        
        if selectedImage != UIImage(named: Constants.userPlacehoderImageName) {
            uploadPicture()
        }
    }
    
    private func handleUpdateUser(model: UpdateUserRequest) {
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        ApiService.shared.updateUser(model) { [weak self] user, error in
            progress.hide(animated: true)
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if let user = user {
                CredentialManager.sharedInstance.currentUser = user
                if self.tabBarController == nil {
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    sceneDelegate?.window?.rootViewController = MainTabBarViewController()
                    sceneDelegate?.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    private func fillData() {
        let user = CredentialManager.sharedInstance.currentUser
        rootView?.setName(user?.name)
        rootView?.setupPhoneNumber(user?.phone)
        rootView?.setBioInfo(user?.description)
        
        if let selectedImage = selectedImage {
            rootView?.avatarImageView.image = selectedImage
        } else {
            rootView?.setUserImage(user?.avatarUrl)
        }
    }
    
    private func showPickMedia() {
        showPickMediaBootomSheet(libraryAction: {
            self.showLibrary(delegate: self)
        }, cameraAction: {
            self.showLibrary(sourceType: .camera, delegate: self)
        }, documentsAction: nil)
    }
    
    private func uploadPicture() {
        guard let selectedImage = selectedImage, let data = selectedImage.pngData(), let mimeType = Swime.mimeType(data: data) else { return }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        
        ApiService.shared.uploadPublicMedia(model: UploadFileRequest(mime: mimeType.mime, name: UUID().uuidString, base64: data.base64EncodedString())) { [weak self] fileId, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            } else if let fileId = fileId {
                CredentialManager.sharedInstance.currentUser?.avatarFileId = fileId
                self.handleUpdateUser(model: UpdateUserRequest(avatarFileId: fileId))
            }
        }
    }
    
}

//MARK: - RootViewGettable

extension ProfileSettingsViewController: RootViewGettable {
    typealias RootViewType = ProfileSettingsView
}


extension ProfileSettingsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return (textView.text as NSString).replacingCharacters(in: range, with: text).count <= 120
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let line = textView.numberOfLine()
        if line <= 4 {
            currentLine = line
            shouldReloadInputUI = currentLine != line
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Bio" {
            textView.text = nil
            textView.textColor = UIColor(named: "#2F385D")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Bio"
            textView.textColor = .lightGray
        }
    }
}

extension ProfileSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage = image
                selectedImageURL = info[.imageURL] as? URL
                rootView?.avatarImageView.image = image
                dismiss(animated: true)
            }
    }
}
