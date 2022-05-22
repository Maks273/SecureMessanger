//
//  ContactsListView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class ContactsListView: UIView {
    
    //MARK: - IBOutlets

    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchTextField: UITextField!
    
    //MARK: - Variables
    
    var refreshAction: (() -> Void)?
    let contactCellID = "ContactListTableViewCell"
    private var isSearchMode: Bool = false {
        didSet {
            searchTextField.isHidden = !isSearchMode
            searchButton.setImage(UIImage(systemName: isSearchMode ? "xmark.circle" : "magnifyingglass"), for: .normal)
        }
    }
    
    //MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }
    
    //MARK: - IBActions
    
    @IBAction private func searchButtonPressed(_ sender: Any) {
        isSearchMode.toggle()
    }
    
    //MARK: - Helper
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func stopRefreshing() {
        tableView.refreshControl?.endRefreshing()
    }
    
    //MARK: - Private methods
    
    private func configureTableView() {
        tableView.register(UINib(nibName: contactCellID, bundle: nil), forCellReuseIdentifier: contactCellID)
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    @objc private func refreshTable() {
        refreshAction?()
    }
    
    
    

}
