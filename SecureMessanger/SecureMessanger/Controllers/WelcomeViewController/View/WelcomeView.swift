//
//  WelcomeView.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit

class WelcomeView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var textView: UITextView!
    
    //MARK: - Variables
    
    var loginAction: (() -> ())?
    var signUpAction: (() -> ())?
    private let termsOfUse = "Terms of Use"
    private let privacyPolicy = "Privacy Policy"
    
    //MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - IBActions
    
    @IBAction private func loginButtonPressed(_ sender: Any) {
        loginAction?()
    }
    
    @IBAction private func signUpButtonPressed(_ sender: Any) {
        signUpAction?()
    }
    
    //MARK: - Helper
    
    func configure(with color: UIColor = UIColor(named: "#2F385D")!) {
        let attributedString = NSMutableAttributedString(string: "By signing up or loging in, you accept our Terms of Use and Privacy Policy", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular), .foregroundColor: color, .kern: -0.96])
        if let termsStartIndex = attributedString.string.range(of: termsOfUse), let termsURL = URL(string: "https://music.youtube.com/watch?v=pRz3PE9Uwgs&list=LM") {
            let termsNSRange = NSRange(location: termsStartIndex.lowerBound.utf16Offset(in: attributedString.string), length: termsOfUse.count)
            attributedString.addAttribute(.link, value: termsURL, range: termsNSRange)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .bold), range: termsNSRange)
        }
        if let privacyStartIndex = attributedString.string.range(of: privacyPolicy), let privacyURL = URL(string: "https://music.youtube.com/watch?v=pRz3PE9Uwgs&list=LM") {
            let privacyNSRange = NSRange(location: privacyStartIndex.lowerBound.utf16Offset(in: attributedString.string), length: privacyPolicy.count)
            attributedString.addAttribute(.link, value: privacyURL, range: privacyNSRange)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .bold), range: privacyNSRange)
        }
        textView.linkTextAttributes = [.foregroundColor: color]
        textView.attributedText = attributedString
        textView.textAlignment = .center
    }
    
    

}
