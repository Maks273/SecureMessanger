//
//  MainTabBarViewController.swift
//  SecureMessanger
//
//  Created by Maksym Paidych on 20.03.2022.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupViewControllers()
        configureTabBarStyle()
    }
    
    private func setupViewControllers() {
        let chatListVC = ChatListViewController()
        chatListVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message"))
        let chatListNavVC = UINavigationController(rootViewController: chatListVC)
        
        
        let contactsListVC = ContactsListViewController()
        contactsListVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.3.sequence"), selectedImage: UIImage(systemName: "person.3.sequence"))
        let contactsListNavVC = UINavigationController(rootViewController: contactsListVC)
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
        let settingsNavVC = UINavigationController(rootViewController: settingsVC)
        
        viewControllers = [chatListNavVC, contactsListNavVC, settingsNavVC]
    }
    
    private func configureTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white
        appearance.selectionIndicatorTintColor = UIColor(named: "#2F385D")
        appearance.configureWithOpaqueBackground()
        
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().tintColor = UIColor(named: "#2F385D")
        UITabBar.appearance().backgroundColor = .white
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
        } else {
        }
    }
}
