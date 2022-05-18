//
//  UIViewController+Extension.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit

extension UIViewController {
    func showAlert(title: String? = nil, message: String? = nil, okTitle: String? = nil, cancelTitle: String? = nil, okAction: ((UIAlertAction) -> Void)? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "#2F385D")

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle = .light

        let retryAction = UIAlertAction(title: okTitle, style: .default, handler: okAction)
        
        
        if cancelAction != nil {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: cancelAction)
            alertController.addAction(cancelAction)
        }
        alertController.addAction(retryAction)
        DispatchQueue.main.async {
            alertController.view.tintColor = UIColor(named: "#2F385D")
            self.present(alertController, animated: true, completion:  nil)
        }
    }
    
    func turnOnDissmissKeyboardOnViewTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapOnView() {
        view.endEditing(true)
    }
    
    func setupDefaultBackButton() {
        let backButton = UIButton()
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = UIColor(named: "#2F385D")
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton)]
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func showTextFieldAlert(title: String, okTitle: String, okActionCompletion: @escaping (_ text: String?) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            okActionCompletion(alert.textFields?.first?.text)
        }
        
        alert.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor(named: "AppRedColor(#FF2828)")
        
        present(alert, animated: true, completion: nil)
    }
}

