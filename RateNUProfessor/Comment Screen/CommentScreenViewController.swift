//
//  CommentScreenViewController.swift
//  RateNUProfessor
//
//  Created by Jiaqi Zhao on 11/14/23.
//

import UIKit
import FirebaseFirestore

class CommentScreenViewController: UIViewController {

    //TODO: 有关view上的Todo
    //TODO: 在页面上方应该有这个professor的平均分
    //TODO: 每个comment展示的部分可以再改一下
    let commentScreen = CommentScreenView()
    // waiting to get the professor selected from the search screen
    var professorObj = Professor(name: "")
    var allScoresList = [SingleRateUnit]()
    var currentUser:FirebaseAuth.User?
    let database = Firestore.firestore()
        
    override func loadView() {
        view = commentScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = professorObj.name

        /// updated below:
        fetchCommentsForProfessor()
        
        commentScreen.tableViewComments.delegate = self
        commentScreen.tableViewComments.dataSource = self
        commentScreen.tableViewComments.separatorStyle = .none
        
        commentScreen.floatingButtonAddComment.addTarget(self, action: #selector(onAddCommentButtonTapped), for: .touchUpInside)
        
    }
    
    
    
    func fetchCommentsForProfessor() {
        let professorUID = professorObj.professorUID
        
        var totalScore = 0.0
        var numberOfScores = 0
        
        let db = Firestore.firestore()
        db.collection("users").getDocuments { [weak self] (userQuerySnapshot, err) in
            if let err = err {
                print("Error getting users: \(err)")
                return
            }
            
            // 清空现有评论列表
            self?.allScoresList.removeAll()
            
            // 用于跟踪异步操作
            let group = DispatchGroup()

            // 遍历每个用户
            for userDocument in userQuerySnapshot!.documents {
                group.enter()
                
                let userData = userDocument.data()
                let user = User(
                    id: userDocument.documentID,
                    name: userData["name"] as? String ?? "",
                    email: userData["email"] as? String ?? "",
                    password: userData["password"] as? String ?? "",
                    campus: userData["campus"] as? String ?? ""
                )

                // 获取与特定教授相关的评论
                db.collection("users").document(userDocument.documentID).collection("comments")
                    .whereField("rateProfessor.professorUID", isEqualTo: self?.professorObj.professorUID ?? "")
                    .getDocuments { (commentQuerySnapshot, err) in
                        if let err = err {
                            print("Error getting comments: \(err)")
                            group.leave() // 离开组
                            return
                        }

                        // 遍历该用户的每条评论
                        for commentDocument in commentQuerySnapshot!.documents {
                            let commentData = commentDocument.data()
                            if let rateScore = commentData["rateScore"] as? Double {
                                totalScore += rateScore
                                numberOfScores += 1
                            }
                        
                            let rate = SingleRateUnit(
                                commentId: commentDocument.documentID,
                                rateStudent: user,
                                rateProfessor: self?.professorObj ?? Professor(name: ""),
                                rateClass: commentData["rateClass"] as? String ?? "",
                                rateScore: commentData["rateScore"] as? Double ?? 0.0,
                                rateComment: commentData["rateComment"] as? String ?? "",
                                rateSemester: commentData["rateSemester"] as? String ?? "",
                                rateCampus: commentData["rateCampus"] as? String ?? ""
                            )
                            self?.allScoresList.append(rate)
                        }
                        
                        group.leave() // 离开组
                    }
            }
                        
            group.notify(queue: .main) {
                // 当所有评论都被处理后，计算平均分
                if numberOfScores > 0 {
                    let averageScore = totalScore / Double(numberOfScores)
                    self?.commentScreen.averageScoreLabel.text = "Average Score: \(averageScore)"
                } else {
                    self?.commentScreen.averageScoreLabel.text = "No Scores Available"
                }
                self?.commentScreen.tableViewComments.reloadData()
            }
        }
    }



    
    @objc func onAddCommentButtonTapped() {
        let addCommentScreenViewController = AddCommentScreenViewController()
        // pass the professor object to Add Comment Screen
        addCommentScreenViewController.professor = professorObj
        navigationController?.pushViewController(addCommentScreenViewController, animated: true)
    }


}



extension CommentScreenViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allScoresList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewCommentsID, for: indexPath) as! CommentTableViewCell
        let curRateItem = allScoresList[indexPath.row]
       
        cell.labelScore.text = "\(curRateItem.rateScore)"
        cell.labelClass.text = "\(curRateItem.rateClass)"
        cell.labelComment.text = "\(curRateItem.rateComment)"
        
        return cell
    }
    
//    func convertToDateAndTime(_ date: TimeInterval? ) -> String? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = .current
//        if let date = date {
//            let date = Date(timeIntervalSince1970: date)
//            dateFormatter.dateFormat = "YY/MM/dd, hh:mm"
//            return dateFormatter.string(from: date)
//        } else {
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


    }

}
