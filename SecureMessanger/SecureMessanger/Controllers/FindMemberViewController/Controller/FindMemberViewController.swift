//
//  FindMemberViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 19.05.2022.
//

import UIKit
import MBProgressHUD

class FindMemberViewController: UIViewController {
    
    var isChatFlow: Bool = true
    var didSelectMember: ((User) -> Void)?
    private var user: User? {
        didSet {
            rootView?.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultBackButton()
        title = "Find member"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func searchMember(phoneNumber: String) {
        guard !phoneNumber.isEmpty else {
            showAlert(title: "Warning", message: "Search text can't be empty", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        
        let progress = MBProgressHUD.showAdded(to: view, animated: true)
        ApiService.shared.searchMember(phoneNumber: phoneNumber) { [weak self] user, error in
            progress.hide(animated: true)
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }
            
            self.user = user
            
            if user == nil {
                self.showAlert(title: "No found", message: "Didn't find the user with that phone number", okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }
            
        }
        
    }

}

extension FindMemberViewController: RootViewGettable {
    typealias RootViewType = FindMemberView
}

extension FindMemberViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let user = user {
            didSelectMember?(user)
            if isChatFlow {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}


extension FindMemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user == nil ? 0 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rootView!.cellID, for: indexPath) as! MemberTableViewCell
        if let user = user {
            cell.configure(model: user)
        }
        return cell
    }
}

extension FindMemberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMember(phoneNumber: textField.text ?? "")
        return true
    }
}
