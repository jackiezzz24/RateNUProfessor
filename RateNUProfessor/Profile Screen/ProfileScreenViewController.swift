//
//  ProfileScreenViewController.swift
//  RateNUProfessor
//
//  Created by Jiaqi Zhao on 11/14/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileScreenViewController: UIViewController {

    let profileScreen = ProfileScreenView()
    var comments = [SingleRateUnit]()
    var currentUser:FirebaseAuth.User?
    let database = Firestore.firestore()
    
    override func loadView() {
        view = profileScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Profile"
        
        currentUser = Auth.auth().currentUser
        print("profilepage: \(currentUser?.uid)")
        
        profileScreen.tableViewComments.delegate = self
        profileScreen.tableViewComments.dataSource = self
        
        profileScreen.tableViewComments.separatorStyle = .none
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(onSettingsBarButtonTapped))
        
        profileScreen.labelName.text = currentUser?.displayName
                
        if let url = currentUser?.photoURL{
            self.profileScreen.profileImage.loadRemoteImage(from: url)
        }
                
        if let id = currentUser?.uid {
            self.database.collection("users").document(id).getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                } else if let document = document, document.exists {
                    let campus = document["campus"] as? String ?? "Unknown"
                    self.profileScreen.labelCampus.text = campus
                } else {
                    print("Document does not exist")
                }
            }
        }
 
        if let id = currentUser?.uid {
            database.collection("users")
                .document(id)
                .collection("comments")
                .addSnapshotListener(includeMetadataChanges: false, listener: {querySnapshot, error in
                    if let documents = querySnapshot?.documents{
                        self.comments.removeAll()
                        for document in documents{
                            do{
                                let comment  = try document.data(as: SingleRateUnit.self)
                                self.comments.append(comment)
                            }catch{
                                print(error)
                            }
                        }
                        self.comments.sort(by: {$0.rateSemaster < $1.rateSemaster})
                        self.profileScreen.tableViewComments.reloadData()
                    }
                })
        }
    }
    
    @objc func onSettingsBarButtonTapped() {
        let settingsController = SettingScreenViewController()
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
}
