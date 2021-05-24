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

class OnlineClassroomVC:UIViewController,UITableViewDelegate,UITableViewDataSource {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var tableViewData = [OnlineClassSectionHeader]()
    @IBOutlet var tblTable: UITableView!
    @IBOutlet weak var btnNew: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Online Classroom"
        
        tblTable.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(Common.shared.userRole == "AppTeacher"){
            btnNew.backgroundColor = .clear
            btnNew.layer.cornerRadius = 5
        } else {
            btnNew.isHidden = true
        }
        
        self.fnShowClassrooms()
    }
    
    @IBAction func btnNewClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        openView(state: self, viewName: "OnlineClassSubmitLinkVC")
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
            cell?.textLabel?.textColor = UIColor.gray
            cell?.textLabel?.textAlignment = .left
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            cell?.backgroundView?.backgroundColor = UIColor.blue
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return (cell)!
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OnlineClassViewCell") as? OnlineClassViewCell else {
                return UITableViewCell()
            }
            let obj:OnlineClass = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            cell.txtSubjectName.text = obj.subjectName
            if(obj.status.lowercased() == "pending"){
                cell.txtDate.text = "Start : \(obj.classStartDate)"
                cell.txtStatus.text = "Pending"
            } else if(obj.status.lowercased() == "running") {
                cell.txtDate.text = "Started : \(obj.classStartDate)"
                cell.txtStatus.text = "Running"
            } else if (obj.status.lowercased() == "completed") {
                cell.txtDate.text = "Completed : \(obj.classStartDate)"
                cell.txtStatus.text = "Completed"
            }
            cell.txtClassName.text = "Class : \(obj.className)"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        } else {
            let obj:OnlineClass = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            let obj:OnlineClass = tableViewData[indexPath.section].sectionData[indexPath.row - 1]
            if(obj.status.lowercased() == "pending" && Common.shared.userRole.lowercased() == "appteacher"){
                //call UpdateOnlineClassStatus api to set to running
                let alert = UIAlertController(title: "Confirm", message: "Update class to Running?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    self.callUpdateClassApi(classjoiningid: obj.id, status: obj.status.lowercased().capitalizingFirstLetter())
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if(obj.status.lowercased() == "running"){
                if(Common.shared.userRole.lowercased() == "appteacher"){
                    //call UpdateOnlineClassStatus api to set to completed
                    
                    let alert = UIAlertController(title: "Confirm", message: "Update class to Completed?", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self.callUpdateClassApi(classjoiningid: obj.id, status: obj.status.lowercased().capitalizingFirstLetter())
                    }))
                    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else if (Common.shared.userRole.lowercased() == "appstudent") {
//                    http://202.51.74.57:908/api/AppData/SumitOnlineClassJoiningRecord?userid=991&classjoiningid=1
                    fnPostApiWithUrlEcoding(url: appUrl + "SumitOnlineClassJoiningRecord?userid=\(Common.shared.userId)&classjoiningid=\(obj.id)", completionHandler:{(res,json) -> Void in
                            if(res && json.stringValue.lowercased().contains("true")){
                                self.showToast(message: "Attendance done!")
                                let url = URL(string: obj.joiningLink)!
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                         print("Open url : \(success)")
                                    })
                                }
                            }else{
                                displayAlertMessage(state: self, msg: "Server error while doing attendance. Please Try Again!")
                            }
                        })
                }
            }
//            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func callUpdateClassApi(classjoiningid:String, status:String){
//        http://202.51.74.57:908/api/AppData/UpdateOnlineClassStatus?userid=1266&teacherid=2&classjoiningid=1
        let url = appUrl + "UpdateOnlineClassStatus?userid=\(Common.shared.userId)&teacherid=\(Common.shared.teacherId)&classjoiningid=\(classjoiningid)"
        
        fnPostApiWithUrlEcoding(url: url, completionHandler: {(res,json)->Void in
            if(res){
                NAMSS.showToast(state: self, message: "Online class to \(status) successfully.")
                self.fnShowClassrooms()
            }else{
                NAMSS.showToast(state: self, message: "Error updating class. Please Try again")
            }
        })
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
    
    func fnShowClassrooms(){
        showProgressBar()
        let url = appUrl + "GetOnlineJoiningClass?userid=\(Common.shared.userId)"
        self.tableViewData.removeAll()
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
                        let runningArray = json["runningClass"].array
                        let pendingArray = json["pendingClass"].array
                        let completedArray = json["completedClass"].array
                        var count = 0
                        var count1 = 0
                        var count2 = 0
                        var id, joiningLink,status,subjectId,subjectName,teacherId,classId,className, classCompletedTime, classRunningTime, classStartDate, createdBy, createdDate: String
                        var pendingList  = [OnlineClass](),runningList = [OnlineClass](),completedList = [OnlineClass]()
                        while(count < runningArray?.count ?? 0){
                            let JO = JSON(runningArray![count])
                            id = JO["Id"].stringValue
                            joiningLink = JO["JoiningLink"].stringValue
                            status = JO["Status"].stringValue
                            subjectId = JO["SubjectId"].stringValue
                            subjectName = JO["SubjectName"].stringValue
                            teacherId = JO["TeacherId"].stringValue
                            classId = JO["ClassId"].stringValue
                            className = JO["ClassName"].stringValue
                            classCompletedTime = JO["ClassCompletedTime"].stringValue
                            classRunningTime = JO["ClassRunningTime"].stringValue
                            classStartDate = JO["ClassStartDate"].stringValue
                            createdBy = JO["createdBy"].stringValue
                            createdDate = JO["createdDate"].stringValue
                            runningList.append(OnlineClass(id: id, joiningLink: joiningLink, status: status, subjectId: subjectId, subjectName: subjectName, teacherId: teacherId, classId: classId, className: className, classCompletedTime: classCompletedTime, classRunningTime: classRunningTime, classStartDate: classStartDate, createdBy: createdBy, createdDate: createdDate))
                            count = count + 1
                        }
                        self.tableViewData.append(OnlineClassSectionHeader(opened: true, title: "Running Class", sectionData: runningList))
                        while(count1 < pendingArray?.count ?? 0){
                            let JO = JSON(pendingArray![count1])
                            id = JO["Id"].stringValue
                            joiningLink = JO["JoiningLink"].stringValue
                            status = JO["Status"].stringValue
                            subjectId = JO["SubjectId"].stringValue
                            subjectName = JO["SubjectName"].stringValue
                            teacherId = JO["TeacherId"].stringValue
                            classId = JO["ClassId"].stringValue
                            className = JO["ClassName"].stringValue
                            classCompletedTime = JO["ClassCompletedTime"].stringValue
                            classRunningTime = JO["ClassRunningTime"].stringValue
                            classStartDate = JO["ClassStartDate"].stringValue
                            createdBy = JO["createdBy"].stringValue
                            createdDate = JO["createdDate"].stringValue
                            pendingList.append(OnlineClass(id: id, joiningLink: joiningLink, status: status, subjectId: subjectId, subjectName: subjectName, teacherId: teacherId, classId: classId, className: className, classCompletedTime: classCompletedTime, classRunningTime: classRunningTime, classStartDate: classStartDate, createdBy: createdBy, createdDate: createdDate))
                            count1 = count1 + 1
                        }
                        self.tableViewData.append(OnlineClassSectionHeader(opened: true, title: "Pending Class", sectionData: pendingList))
                        while(count2 < completedArray?.count ?? 0){
                            let JO = JSON(completedArray![count2])
                            id = JO["Id"].stringValue
                            joiningLink = JO["JoiningLink"].stringValue
                            status = JO["Status"].stringValue
                            subjectId = JO["SubjectId"].stringValue
                            subjectName = JO["SubjectName"].stringValue
                            teacherId = JO["TeacherId"].stringValue
                            classId = JO["ClassId"].stringValue
                            className = JO["ClassName"].stringValue
                            classCompletedTime = JO["ClassCompletedTime"].stringValue
                            classRunningTime = JO["ClassRunningTime"].stringValue
                            classStartDate = JO["ClassStartDate"].stringValue
                            createdBy = JO["createdBy"].stringValue
                            createdDate = JO["createdDate"].stringValue
                            completedList.append(OnlineClass(id: id, joiningLink: joiningLink, status: status, subjectId: subjectId, subjectName: subjectName, teacherId: teacherId, classId: classId, className: className, classCompletedTime: classCompletedTime, classRunningTime: classRunningTime, classStartDate: classStartDate, createdBy: createdBy, createdDate: createdDate))
                            count2 = count2 + 1
                        }
                        self.tableViewData.append(OnlineClassSectionHeader(opened: true, title: "Completed Class", sectionData: completedList))
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
