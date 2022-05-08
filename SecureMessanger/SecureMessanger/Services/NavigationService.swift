//
//  NavigationService.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 18.03.2022.
//

import UIKit

class NavigationService {
    
    private init() {}
    
    static let shared = NavigationService()
    
    func navigationControllerFor(viewController: UIViewController) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: viewController)
       // navigationController.navigationBar.barTintColor = Colors.navigationBarColor
        //navigationController.navigationBar.tintColor = Colors.friendsBlueColor
        if #available(iOS 13.0, *) {
//            let navBarAppearance = UINavigationBarAppearance()
//            navBarAppearance.configureWithOpaqueBackground()
//            navBarAppearance.backgroundColor = Colors.navigationBarColor
//            navigationController.navigationBar.standardAppearance = navBarAppearance
//            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        return navigationController
    }
}
