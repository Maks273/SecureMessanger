//
//  ContactsListViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit
import MBProgressHUD

class ContactsListViewController: UIViewController {
    
    private var pageIndex: Int = 0
    private var nextAvailability: Bool = false
    private var contacts: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = false
        fetchContacts()
    }
    
    private func fetchContacts(showProgress: Bool = true) {
        var progress: MBProgressHUD?
        
        if showProgress {
            progress = MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        ApiService.shared.fetchContacts(pageIndex: pageIndex, pageSize: 20) { [weak self] response, error in
            progress?.hide(animated: true)
            self?.rootView?.stopRefreshing()
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "Ok", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else if let response = response {
                self.nextAvailability = response.totalPages != self.pageIndex
                self.updateContactsList(result: response.items)
            }
        }
    }
    
    private func configureView() {
        rootView?.refreshAction = { [weak self] in
            self?.pageIndex = 0
            self?.fetchContacts(showProgress: false)
        }
        
        rootView?.addContactAction = { [weak self] in
            self?.showFindMemberVC()
        }
    }
    
    private func updateContactsList(result: [User]) {
        if pageIndex == 0 {
            self.contacts = []
        }
        self.contacts.append(contentsOf: result)
        self.rootView?.reloadData()
    }
    
    private func showContactProfile(user: User) {
        let vc = ProfileDetailViewController()
        vc.didUpdateUser = { [weak self] user in
            // remove or add into a contacts list
        }
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showFindMemberVC() {
        let vc = FindMemberViewController()
        vc.isChatFlow = false
        vc.didSelectMember = { [weak self] member in
            self?.showContactProfile(user: member)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - RootViewGettable

extension ContactsListViewController: RootViewGettable {
    typealias RootViewType = ContactsListView
}

//MARK: - UITableViewDelegate

extension ContactsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < contacts.count {
            showContactProfile(user: contacts[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return contacts.isEmpty ? tableView.frame.height/2 : 0
    }
}

//MARK: - UITableViewDataSource

extension ContactsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rootView!.contactCellID, for: indexPath) as! ContactListTableViewCell
        if indexPath.row < contacts.count {
            cell.configure(with: contacts[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if nextAvailability && indexPath.row == contacts.count - 5 {
            pageIndex += 1
            fetchContacts()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TableViewPlaceholderView()
        view.configure(title: "No contacts in your contacts list")
        return contacts.isEmpty ? view : nil
    }
}

