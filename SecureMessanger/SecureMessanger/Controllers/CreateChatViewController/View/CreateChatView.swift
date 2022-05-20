//
//  CreateChatView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 19.05.2022.
//

import UIKit

class CreateChatView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    let cellID = "MemberTableViewCell"
    
    var createChatAction: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }

    @IBAction func createButtonPressed(_ sender: Any) {
        createChatAction?()
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}
