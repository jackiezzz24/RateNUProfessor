//
//  TabBarScreenViewController.swift
//  RateNUProfessor
//
//  Created by 陈可轩 on 2023/11/19.
//

import UIKit

class TabBarScreenViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabSearch = UINavigationController(rootViewController: SearchScreenViewController())
        let tabSearchBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass.circle")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(systemName: "magnifyingglass.circle.fill")
        )
        tabSearch.tabBarItem = tabSearchBarItem
        tabSearch.title = "Search"
        
        let tabProfile = UINavigationController(rootViewController: ProfileScreenViewController())
        let tabProfileBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(systemName: "person.fill")
        )
        tabProfile.tabBarItem = tabProfileBarItem
        tabProfile.title = "Profile"
        
        self.viewControllers = [tabSearch, tabProfile]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

}
