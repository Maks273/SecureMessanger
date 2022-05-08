//
//  RootViewProtocol.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit

protocol RootViewGettable {
    
    associatedtype RootViewType: UIView
    
    var rootView: RootViewType? { get }
}

extension RootViewGettable where Self : UIViewController {
    
    var rootView: RootViewType? { return self.view as? RootViewType }
}
