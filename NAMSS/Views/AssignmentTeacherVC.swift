//
//  AssignmentTeacherVC.swift
//  NAMSS
//
//  Created by ITH on 26/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AssignmentTeacherVC: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tblAssignment: UITableView!
    private var list = [AssignmentV2]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "View Assignments"
        tblAssignment.tableFooterView = UIView()
        self.fnShowAssignments()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func fnShowAssignments(){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        //        let today = formatter.string(from: Date())
        let url = appUrlV2 + "GetClassHomeworkByTeacher?teacherid=\(Common.shared.teacherId)&date="
        self.list.removeAll()
        Alamofire.request(url, method: .get)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if(json["ExceptionType"].stringValue == "" && json["Message"].stringValue == ""){
                            
                            for (index,subJson):(String, JSON) in JSON(json){
                                
                                var homeworkId, className,subjectName,homeworkDateEn,homeworkDate,homeworkDescription,teacherName,imageUrl,submissionDateEn,submissionDate,status: String
                                
                                homeworkId = subJson["ClassHomeworkId"].stringValue
                                className = subJson["ClassName"].stringValue
                                subjectName = subJson["SubjectName"].stringValue
                                homeworkDateEn = subJson["homeworkDateEn"].stringValue == "" ? "" : String(subJson["homeworkDateEn"].stringValue.split(separator: ".")[0])
                                homeworkDate = subJson["homeworkDate"].stringValue
                                homeworkDescription = subJson["HomeworkDescription"].stringValue
                                teacherName = subJson["TeacherName"].stringValue
                                imageUrl = subJson["ImageUrl"].stringValue.replacingOccurrences(of: "~", with: baseUrl)
                                submissionDateEn = subJson["SubmissionDateEn"].stringValue != "" ? String(subJson["SubmissionDateEn"].stringValue.split(separator: ".")[0]) : ""
                                submissionDate = subJson["SubmissionDate"].stringValue
                                status = subJson["Status"].stringValue
                                
                                self.list.append(AssignmentV2(homeworkId: homeworkId, className: className, subjectName: subjectName, homeworkDateEn: homeworkDateEn, homeworkDate: homeworkDate, homeworkDescription: homeworkDescription, teacherName: teacherName, imageUrl: imageUrl, submissionDateEn: submissionDateEn, submissionDate: submissionDate, status: status))
                                
                            }
                            
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblAssignment.reloadData()
                        } else {
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblAssignment.reloadData()
                            showToast(state: self, message: exceptionMessage)
                        }
                    }
                case .failure(let error):
                    print(error)
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    self.tblAssignment.reloadData()
                    showToast(state: self, message: exceptionMessage)
                }
            }
    }
    
    func showImage(url:String)
    {
        let plusIcon = UIImage(named: "")
        let newImageView = UIImageView(image: plusIcon)
        newImageView.kf.setImage(with: URL(string: url))
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(sender:)))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
}

extension AssignmentTeacherVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            tblAssignment.setEmptyMessage("No data available!")
        } else {
            tblAssignment.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentTeacherViewCell", for: indexPath) as? AssignmentTeacherViewCell else{
            return UITableViewCell()
        }
        let obj:AssignmentV2 = list[indexPath.row]
        //        cell.textLabel!.text = list[indexPath.row].leaveName
        cell.txtClassName.text = "Class: " + obj.className
        cell.txtSubject.text = obj.subjectName
        cell.txtDescription.text = obj.homeworkDescription
        cell.txtAssignee.text = "Teacher: " + obj.teacherName
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let homeworkDate = formatter.date(from: obj.homeworkDateEn) ?? Date()
        let submissionDate = formatter.date(from: obj.submissionDateEn) ?? Date()
        formatter.dateFormat = "dd MMMM ',' h:mm a"
        cell.txtHomeworkDate.text = "Assinged : \(formatter.string(from: homeworkDate))"
        cell.txtSubmisionDate.text = "Submission : \(formatter.string(from: submissionDate))"
        
        var imgUrl = obj.imageUrl
        //        imgUrl =  "https://image.shutterstock.com/image-vector/sample-stamp-grunge-texture-vector-600w-1389188327.jpg"
        
        cell.imgAssignment.kf.setImage(with: URL(string: imgUrl), completionHandler:  {
            result in
            switch result {
            case  .success(_):
                print("Image set")
            case .failure(let error):
                print(error)
            }
        })
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj:AssignmentV2 = list[indexPath.row]
        let storyboard = AppStoryboard.ClassActivity.instance
        let VC =  storyboard.instantiateViewController(withIdentifier: "StudentListVC") as! StudentListVC
        VC.homeworkId = obj.homeworkId
        VC.assignmentUrl = obj.imageUrl
        VC.list = [String]()
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.pushViewController(VC, animated: true)
//        let VC =  storyboard.instantiateViewController(withIdentifier: "AssignmentTeachContentVC") as! AssignmentTeachContentVC
//        VC.homeworkId = obj.homeworkId
//        VC.assignmentUrl = obj.imageUrl
//        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.pushViewController(VC, animated: true)
    }
}
