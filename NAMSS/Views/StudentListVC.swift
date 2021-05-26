//
//  StudentListVC.swift
//  NAMSS
//
//  Created by ITH on 26/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StudentListVC: UIViewController {

    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tblTable: UITableView!
    var homeworkId = ""
    var assignmentUrl = ""
    var list = [String]()
    var studentDict = [String:AssignmentContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fnGetAssignmentDetail()
        tblTable.tableFooterView = UIView()
        tblTable.reloadData()
    }
    
    func fnGetAssignmentDetail(){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let url = appUrl + "GetSubmittedHomeworkDetailForTeacher?userid=\(Common.shared.userId)&classHomeWorkId=\(self.homeworkId)"
        self.studentDict.removeAll()
        Alamofire.request(url, method: .post)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if(json["ExceptionType"].stringValue == "" && json["Message"].stringValue == ""){
                            
                            let jsonArray = json.array ?? []
                            let homeworkJson = jsonArray.last ?? JSON()
                            
                            var assignmentId:String,studentUserId:String,studentId:String,homeworkId:String,submissionDate:String,studentName:String,className:String,sectionName:String,homeworkName:String,remarks:String,teacherRemarks:String,teacherUserId:String,teacherFeedbackDate:String
                            
                            for (_,homeworkJson):(String, JSON) in JSON(jsonArray ){
                                
                                assignmentId = homeworkJson["Id"].stringValue
                                studentUserId = homeworkJson["StudentUserId"].stringValue
                                studentId = homeworkJson["StudentId"].stringValue
                                homeworkId = homeworkJson["ClassHomeworkId"].stringValue
                                submissionDate = homeworkJson["SubmissionDate"].stringValue
                                studentName = homeworkJson["StudentName"].stringValue
                                className = homeworkJson["ClassName"].stringValue
                                sectionName = homeworkJson["SectionName"].stringValue
                                homeworkName = homeworkJson["HomeworkName"].stringValue
                                remarks = ""
                                teacherRemarks = ""
                                teacherUserId = ""
                                teacherFeedbackDate = ""
                                let values = homeworkJson["homeWorkFile"].array
                                var files = [String]()
                                
                                for (_,subJson):(String, JSON) in JSON(values){
                                    remarks = subJson["Remarks"].stringValue
                                    teacherRemarks = subJson["TeachersRemark"].stringValue
                                    teacherUserId = subJson["TeachersUserId"].stringValue
                                    teacherFeedbackDate = subJson["TeacherFeedbackDate"].stringValue
                                    let fileUrl = subJson["DocumentUrl"].stringValue.replacingOccurrences(of: "~", with: baseUrl)
                                    
                                    files.append(fileUrl)
                                }
                                
                                let assignmentContent = AssignmentContent(assignmentId: assignmentId, studentUserId: studentUserId, studentId: studentId, homeworkId: homeworkId, submissionDate: submissionDate, studentName: studentName, className: className, sectionName: sectionName, homeworkName: homeworkName, remarks: remarks, teacherMarks: teacherRemarks, teacherUserId: teacherUserId, teacherFeedbackDate: teacherFeedbackDate, filesList: files)
                                if self.studentDict[studentName] == nil {
                                    self.studentDict[studentName] = assignmentContent
                                } else {
                                    self.studentDict[studentName]?.filesList.append(contentsOf: files)
                                }
                                
                            }
                            
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblTable.reloadData()
                        } else {
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblTable.reloadData()
                            showToast(state: self, message: exceptionMessage)
                        }
                    }
                case .failure(let error):
                    print(error)
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    self.tblTable.reloadData()
                    showToast(state: self, message: exceptionMessage)
                }
            }
    }

}

extension StudentListVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentDict.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tblTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let studentNameArray = [String](studentDict.keys)
        cell?.textLabel?.text = studentNameArray[indexPath.row]
        cell?.textLabel?.textColor = UIColor.darkGray
        cell?.textLabel?.textAlignment = .left
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        cell?.backgroundView?.backgroundColor = UIColor.blue
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.separatorInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return (cell)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let studentName = (cell?.textLabel?.text)!
        let assignmentObj = self.studentDict[studentName]
        let storyboard = AppStoryboard.ClassActivity.instance
        let VC =  storyboard.instantiateViewController(withIdentifier: "AssignmentTeachContentVC") as! AssignmentTeachContentVC
        VC.assignmentUrl = self.assignmentUrl
        VC.assignment = assignmentObj!
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}
