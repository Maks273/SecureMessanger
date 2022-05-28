//
//  ChatDetailView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 22.05.2022.
//

import UIKit

class ChatDetailView: UIView {
    
    @IBOutlet private weak var avatarButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var phoneTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private var controlButtons: [UIButton]!
    @IBOutlet private weak var phoneNumberHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var addMemberHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var addMembersButton: UIButton!
    
    var addMemberAction: (() -> Void)?
    var controlAction: ((_ index: Int) -> Void)?
    let contactCellID = "ContactListTableViewCell"
    var currentControlIndex: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }
    
    @IBAction func membersButtonPressed(_ sender: Any) {
        changeSelectionStyle(index: 0)
        controlAction?(0)
    }
    
    @IBAction func mediaButtonPressed(_ sender: Any) {
        changeSelectionStyle(index: 1)
        controlAction?(1)
    }
    
    @IBAction func filesButtonPressed(_ sender: Any) {
        changeSelectionStyle(index: 2)
        controlAction?(2)
    }
    
    @IBAction func addMemberButtonPressed(_ sender: Any) {
        addMemberAction?()
    }
    
    func configure(chatName: String, imageURL: String, phoneNumber: String?, isGroup: Bool) {
        nameTextField.text = chatName
        phoneTextField.text = phoneNumber
        phoneNumberHeightConstraint.constant = isGroup ? 0 : 40
        addMemberHeightConstraint.constant = !isGroup ? 0 : 50
        addMembersButton.isHidden = !isGroup
        controlButtons.first?.isHidden = !isGroup
        nameTextField.isUserInteractionEnabled = isGroup
        avatarButton.sd_setImage(with: URL(string: imageURL), for: .normal, placeholderImage: isGroup ? UIImage(systemName: Constants.chatPlaceholderImageName) : UIImage(named: Constants.userPlacehoderImageName))
        avatarButton.imageView?.contentMode = .scaleAspectFill
    }
    
    func changeSelectionStyle(index: Int) {
        currentControlIndex = index
        controlButtons.forEach { $0.setTitleColor(.systemGray2, for: .normal)}
        controlButtons[index].setTitleColor(UIColor(named: "#2F385D"), for: .normal)
        addMemberHeightConstraint.constant = currentControlIndex == 0 ? 50 : 0
        addMembersButton.isHidden = currentControlIndex != 0

    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: contactCellID, bundle: nil), forCellReuseIdentifier: contactCellID)
    }
}
