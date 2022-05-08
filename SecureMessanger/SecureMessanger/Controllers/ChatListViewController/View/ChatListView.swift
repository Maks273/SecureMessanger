//
//  ChatListView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class ChatListView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchButton: UIButton!
    
    //MARK: - Variables
    
    let chatCellID = "ChatListTableViewCell"
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
    
    //MARK: - Private methods
    
    private func configureTableView() {
        tableView.register(UINib(nibName: chatCellID, bundle: nil), forCellReuseIdentifier: chatCellID)
        //TODO: - Add refresh controll
    }

}
