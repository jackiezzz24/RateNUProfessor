//
//  ProfileScreenViewController.swift
//  RateNUProfessor
//
//  Created by Jiaqi Zhao on 11/14/23.
//

import UIKit

class ProfileScreenViewController: UIViewController {

    let profileScreen = ProfileScreenView()
    
    override func loadView() {
        view = profileScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Profile"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(onSettingsBarButtonTapped))
    }
    
    @objc func onSettingsBarButtonTapped() {
        let settingsController = SettingScreenViewController()
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
}
