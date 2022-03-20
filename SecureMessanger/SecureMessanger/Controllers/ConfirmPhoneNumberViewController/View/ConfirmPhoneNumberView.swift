//
//  ConfirmPhoneNumberView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit

class ConfirmPhoneNumberView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var numberLabel: UILabel!
    
    //MARK: - Variables
    
    var nextAction: ((_ code: String) -> ())?
    
    //MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - IBActions
    
    @IBAction private func nextButtonPressed(_ sender: Any) {
        nextAction?("")
    }
    
    //MARK: - Helper
    
    
}
