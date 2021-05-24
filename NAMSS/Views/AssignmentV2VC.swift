//
//  OnlineClassroomVC.swift
//  NAMSS
//
//  Created by ITH on 16/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AssignmentV2VC:UIViewController,UITableViewDelegate,UITableViewDataSource {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var tableViewData = [AssignmentV2SectionHeader]()
    @IBOutlet var tblTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Assignment"
        
        tblTable.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fnShowAssignmentsV2()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableViewData[section].opened == true{
            return tableViewData[section].sectionData.count + 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = tableViewData[indexPath.section].title
            cell?.textLabel?.textColor = UIColor.black
            cell?.textLabel?.textAlignment = .left
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            cell?.backgroundView?.backgroundColor = UIColor.blue
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return (cell)!
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentV2ViewCell") as? AssignmentV2ViewCell else {
                return UITableViewCell()
            }
            let obj:AssignmentV2 = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            cell.txtSubjectName.text = obj.subjectName
            cell.txtRemarks.text = "Remarks: \(obj.homeworkDescription)"
            cell.txtStatus.text = obj.status
            
            let submissionDateEn = obj.submissionDateEn
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            print(submissionDateEn)
            let convertedDate = formatter.date(from: submissionDateEn) ?? Date()
            formatter.dateFormat = "dd MMMM ',' h:mm a"
            cell.txtDeadline.text = "Deadline : \(formatter.string(from: convertedDate))"
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        } else {
            let obj:AssignmentV2 = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            let obj:AssignmentV2 = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            
        }
    }
    
    func callUpdateClassApi(classjoiningid:String, status:String){
//        http://202.51.74.57:908/api/AppData/UpdateOnlineClassStatus?userid=1266&teacherid=2&classjoiningid=1
//        let url = appUrl + "UpdateOnlineClassStatus?userid=\(Common.shared.userId)&teacherid=\(Common.shared.teacherId)&classjoiningid=\(classjoiningid)"
//
//        fnPostApiWithUrlEcoding(url: url, completionHandler: {(res,json)->Void in
//            if(res){
//                NAMSS.showToast(state: self, message: "Online class to \(status) successfully.")
//                self.fnShowClassrooms()
//            }else{
//                NAMSS.showToast(state: self, message: "Error updating class. Please Try again")
//            }
//        })
    }
    
    func showToast(message: String) {
        let toastLabel = UITextView(frame: CGRect(x: self.view.frame.size.width/16, y: self.view.frame.size.height-150, width: self.view.frame.size.width * 7/8, height: 45))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = "   \(message)   "
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.font = UIFont(name: (toastLabel.font?.fontName)!, size: 16)
        toastLabel.center.x = self.view.frame.size.width/2
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func fnShowAssignmentsV2(){
        showProgressBar()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let url = appUrlV2 + "GetClassHomework?userid=\(Common.shared.userId)&studentid=\(Common.shared.studentId)&date=\(formatter.string(from: Date()))"
        self.tableViewData.removeAll()
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
                            
                            let date = subJson["Date"].stringValue
                            let values = subJson["Values"].array
                            var assignmentList = [AssignmentV2]()
                            
                            var homeworkId, className,subjectName,homeworkDateEn,homeworkDate,homeworkDescription,teacherName,imageUrl,submissionDateEn,submissionDate,status: String
                            
                            for (index,subJson):(String, JSON) in JSON(values ?? []){
                                homeworkId = subJson["ClassHomeworkId"].stringValue
                                className = subJson["ClassName"].stringValue
                                subjectName = subJson["SubjectName"].stringValue
                                homeworkDateEn = subJson["homeworkDateEn"].stringValue
                                homeworkDate = subJson["homeworkDate"].stringValue
                                homeworkDescription = subJson["HomeworkDescription"].stringValue
                                teacherName = subJson["TeacherName"].stringValue
                                imageUrl = subJson["ImageUrl"].stringValue
                                submissionDateEn = subJson["SubmissionDateEn"].stringValue
                                submissionDate = subJson["SubmissionDate"].stringValue
                                status = subJson["Status"].stringValue
                                
                                assignmentList.append(AssignmentV2(homeworkId: homeworkId, className: className, subjectName: subjectName, homeworkDateEn: homeworkDateEn, homeworkDate: homeworkDate, homeworkDescription: homeworkDescription, teacherName: teacherName, imageUrl: imageUrl, submissionDateEn: submissionDateEn, submissionDate: submissionDate, status: status))
                            }
                            self.tableViewData.append(AssignmentV2SectionHeader(opened: true, title: date, sectionData: assignmentList))
                        }
                        
                        self.hideProgressBar()
                        self.tblTable.reloadData()
                    } else {
                        self.hideProgressBar()
                        self.tblTable.reloadData()
                        self.showToast(message: exceptionMessage)
                    }
                }
            case .failure(let error):
                print(error)
                self.hideProgressBar()
                self.tblTable.reloadData()
                self.showToast(message: exceptionMessage)
            }
        }
    }
    
    func showProgressBar(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    func hideProgressBar(){
        activityIndicator.stopAnimating()
    }
    
}
