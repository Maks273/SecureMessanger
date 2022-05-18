//
//  LoginViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit
import FlagPhoneNumber
import MBProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - Variables
    
    private var selectedCode: String = FlagPhoneNumber.FPNCountryCode.UA.rawValue
    private var isValidNumber: Bool = false
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        turnOnDissmissKeyboardOnViewTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    //MARK: - Private methods
    
    private func configureView() {
        rootView?.nextAction = { [weak self] in
            guard let self = self, self.isValidNumber, let number = self.rootView?.phoneNumber() else {
                self?.showAlert(title: "Warning", message: "Your phone number isn't valid", okTitle: "OK", okAction: nil)
                return
            }
            
            let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
            ApiService.shared.registerUser(phoneNumber: number) { [weak self] user, error in
                progress.hide(animated: true)
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else {
                    self.showConfirmNumberVC(number: number)
                }
            }
        }
    }
   
    private func showConfirmNumberVC(number: String) {
        let vc = ConfirmPhoneNumberViewController()
        vc.phoneNumber = number
        navigationController?.pushViewController(vc, animated: true)
    }

}

//MARK: - RootViewGettable

extension LoginViewController: RootViewGettable {
    typealias RootViewType = LoginView
}

//MARK: - FPNTextFieldDelegate

extension LoginViewController: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        selectedCode = dialCode
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        isValidNumber = isValid
    }
    
    func fpnDisplayCountryList() {
        let navigationViewController = UINavigationController(rootViewController: self)
        present(navigationViewController, animated: true, completion: nil)
    }

}
