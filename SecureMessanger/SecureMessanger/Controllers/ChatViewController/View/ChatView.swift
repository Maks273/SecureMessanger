//
//  ChatView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 21.03.2022.
//

import UIKit

class ChatView: UIView {
    
    var backAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        backAction?()
    }
}
