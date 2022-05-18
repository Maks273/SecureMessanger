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
    @IBOutlet var codeTextFields: [UITextField]!
    
    //MARK: - Variables
    
    var nextAction: ((_ code: String) -> ())?
    var resendCodeAction: (() -> ())?
    
    //MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
        codeTextFields.forEach { textField in
            textField.delegate = self
        }
    }
    
    //MARK: - IBActions
    
    @IBAction private func nextButtonPressed(_ sender: Any) {
        nextAction?("")
    }
    
    @IBAction func resendCodeButtonPressed(_ sender: Any) {
        resendCodeAction?()
    }
    
    //MARK: - Helper
    
    func approveCode() -> String {
        return codeTextFields.map({$0.text ?? ""}).joined(separator: "")
    }
    
    
}

extension ConfirmPhoneNumberView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if !(string == "") {
                textField.text = string
                let index = textField.tag + 1
                if index < codeTextFields.count {
                    codeTextFields[index].becomeFirstResponder()
                }
                return false
            }
            return true
        }
}
