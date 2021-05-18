//
//  ParentFeedbackVC.swift
//  MMIHS
//
//  Created by Frost on 4/21/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ParentFeedbackVC: UIViewController {

    @IBOutlet weak var tblFeedback: UITableView!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [ParentFeedback]()
    @IBOutlet weak var btnNew: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        var feedbackUrl = appUrl + "GetFeedbacks?userid=\(Common.shared.userId)&readall=true"
        if(Common.shared.userRole == "AppStudent"){
            feedbackUrl = appUrl + "GetFeedbacks?userid=\(Common.shared.parentId)&readall=true"
        }
        fnGetFeedbacks(url: feedbackUrl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblFeedback.rowHeight = 115
        self.tblFeedback.tableFooterView = UIView()
        
        if(Common.shared.userRole != "AppParent") {
            self.title = "Parent Feedbacks"
            self.btnNew.isHidden = true
        } else {
            self.title = "Feedbacks"
            self.btnNew.layer.cornerRadius = 30
            self.btnNew.clipsToBounds = true
        }
        
        var feedbackUrl = appUrl + "GetFeedbacks?userid=\(Common.shared.userId)&readall=true"
        if(Common.shared.userRole == "AppStudent"){
            feedbackUrl = appUrl + "GetFeedbacks?userid=\(Common.shared.parentId)&readall=true"
        }
        
        fnGetFeedbacks(url: feedbackUrl)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func fnNew(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC =  storyboard.instantiateViewController(withIdentifier: "sendFeedbackPopupVC")
                VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                self.addChild(VC)
        //        VC!.view.frame = self.view.frame
                self.view.addSubview(VC.view)
        //        VC?.didMove(toParent: self)
    }
    
    func fnGetFeedbacks(url:String){
        self.list.removeAll()
        showProgressBar(state: self, activityIndicator: activityIndicator)
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
                            if json == []{
//                                showToast(state: self, message: "No Feedbacks.")
                            }else{
                                for (index,subJson):(String, JSON) in json {
                                    self.list.append(ParentFeedback(id: subJson["Id"].stringValue, userid: subJson["UserId"].stringValue, studentname: subJson["StudentName"].stringValue, facultyname: subJson["FACULTYNAME"].stringValue, departmentName: subJson["DEPARTMENTNAME"].stringValue, className: subJson["CLASSNAME"].stringValue, batchName: subJson["BatchName"].stringValue, registerDateNp: subJson["RegisterDateNp"].stringValue, registerDateEn: subJson["RegisterDateEn"].stringValue, staffName: subJson["StaffName"].stringValue, feedbackDetail: subJson["FeedbackDetail"].stringValue, feedbackImageUrl: subJson["FeedbackImageUrl"].stringValue, feedbackStatus: subJson["FeedbackStatus"].stringValue, feedbackResponseBy: subJson["FeedbackResponseBy"].stringValue, feedbackResponseDateNp: subJson["FeedbackResponseDatNp"].stringValue, feedbackResponseDateEn: subJson["FeedbackResponseDate"].stringValue, feedbackResponseDetail: subJson["FeedbackResponseDetail"].stringValue))
                                }
                            }
                        }else{
                            showToast(state: self, message: exceptionMessage)
                        }
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblFeedback.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    showToast(state: self, message: "Network error")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
    }
    
}

extension ParentFeedbackVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            self.tblFeedback.setEmptyMessage("No any Feedbacks.")
        } else {
            self.tblFeedback.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "parentFeedbackViewCell", for: indexPath) as? ParentFeedbackViewCell else {
            return UITableViewCell()
        }
        let obj:ParentFeedback = list[indexPath.row]
        cell.txtDate.text = obj.registerDateNp
        cell.txtTitle.text = obj.feedbackDetail
        if(Common.shared.userRole == "AppParent") {
            cell.txtDesc.text = obj.staffName
        } else {
            cell.txtDesc.text = obj.studentname + " to " + obj.staffName
        }
        cell.txtStatus.text = obj.feedbackStatus
        cell.txtResponseDate.text = obj.feedbackResponseDateNp
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj:ParentFeedback = list[indexPath.row]
        if(obj.feedbackDetail.count > 48){
            return 128;
        } else {
            return 110;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj:ParentFeedback = list[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "feedbackConversationVC") as! FeedbackConversationVC
        VC.feedback = obj
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}

