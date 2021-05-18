//
//  FeedbackConversationVC.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 12/29/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeedbackConversationVC: UIViewController {
    
    var feedback:ParentFeedback = ParentFeedback()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtSentTo: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var txtResponseDate: UILabel!
    @IBOutlet weak var txtResponseFrom: UILabel!
    @IBOutlet weak var txtResponseMessage: UILabel!
    @IBOutlet weak var txtResponse: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtFeedbackFrom: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtDate.text = "Date: " + feedback.registerDateNp
        self.txtSentTo.text = "Sent To: " + feedback.staffName
        self.txtFeedbackFrom.text = "Feedback From: " + feedback.studentname
        self.txtMessage.text = feedback.feedbackDetail
        
        self.txtResponseDate.text = feedback.feedbackResponseDateNp != "" ? "Response Date: " + feedback.feedbackResponseDateNp : ""
        self.txtResponseFrom.text = feedback.feedbackResponseBy != "" ? "Response From: " + feedback.feedbackResponseBy : ""
        self.txtResponseMessage.text = feedback.feedbackResponseDetail

        if(Common.shared.userRole == "AppParent") {
            self.txtResponse.isHidden = true
            self.btnSend.isHidden = true
        }
        
//        if(feedback.feedbackResponseDateEn != ""){
//            self.txtResponse.isHidden = true
//            self.btnSend.isHidden = true
//        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func fnReply(_ sender: Any) {
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        self.view.endEditing(true)
        if(self.txtResponse.text == ""){
            displayAlertMessage(state: self, msg: "Message Empty!")
        } else {
            var requestJson:[String:String] = ["Id":feedback.id,"FeedbackResponseDetail":self.txtResponse.text ?? ""]
            
            fnPostApiWithJson(url: appUrl + "SubmitFeedbackReponse?userid=\(Common.shared.userId)", json: JSON(requestJson), completionHandler:{(res,json) -> Void in
                    if(res && json.stringValue.lowercased().contains("true")){
                        showToast(state: self, message: "Message sent successfully.")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            self.navigationController?.popViewController(animated: true)
//                            openView(state: self, viewName: "parentFeedbackVC")
                        });
                    }else{
                        displayAlertMessage(state: self, msg: "Server error. Please Try Again!")
                    }
                hideProgressBar(activityIndicator: self.activityIndicator)
                })
        }
    }
}
