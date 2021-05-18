//
//  SendFeedbackPopupVC.swift
//  MMIHS
//
//  Created by Frost on 5/4/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import SwiftyJSON

class SendFeedbackPopupVC: UIViewController {
    
    @IBOutlet weak var dropdownStaff: UITextField!
    @IBOutlet weak var txtMessage: UITextView!
    var staffId = "1"
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var globalList = [SimpleObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
//        self.loadStaff()
        
    }
    
    func loadStaff(){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        var list = [SimpleObject]()
        fnGetApi(url: appUrl + "GetAllStaffList", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    list.append(SimpleObject(id: subJson["UserId"].stringValue, name: subJson["StaffName"].stringValue))
                }
                self.globalList = list
                self.dropdownStaff.loadDropdownData(data: list, type:"staff", completionHandler: {(res) in
                    self.staffId = res.id
                })
            }else{
                showToast(state: self, message: "Error getting staff list.")
            }
            hideProgressBar(activityIndicator: self.activityIndicator)
        })
    }

    @IBAction func btnDone(_ sender: Any) {
        if(self.staffId == "") {
            displayAlertMessage(state: self, msg: "Select any staff before sending feedback.")
        } else if (txtMessage.text == "") {
            displayAlertMessage(state: self, msg: "Empty Message!")
        } else {
            
            var requestJson:[String:String] = ["UserId":Common.shared.userId,"IsParent":"true","ReceiverUserId":self.staffId,"FeedbackDetail":txtMessage.text]
            
            fnPostApiWithJson(url: appUrl + "SubmitFeedback", json: JSON(requestJson), completionHandler:{(res,json) -> Void in
                    if(res && json.stringValue.lowercased().contains("true")){
                        showToast(state: self, message: "Feedback sent successfully.")
                        self.removeAnimate()
                    }else{
                        displayAlertMessage(state: self, msg: "Server error. Please Try Again!")
                    }
                })
        }
//        dismiss(animated: true, completion: nil)
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
        removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }
    
}
