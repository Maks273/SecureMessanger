//
//  FindMemberView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 19.05.2022.
//

import UIKit

class FindMemberView: UIView {
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let cellID = "MemberTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    

}
