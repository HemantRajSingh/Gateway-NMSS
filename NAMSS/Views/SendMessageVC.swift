//
//  SendMessageVC.swift
//  MMIHS
//
//  Created by Frost on 5/25/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SendMessageVC: UIViewController {

    @IBOutlet weak var txtMessage: UITextView!
    var list = [Student]()
    var isForAllStudent = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(StaffAttendanceReportVC.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        self.postMessage()
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func postMessage(){
        
        var jsonArray = [Dictionary<String, String>]()
        var json = [String:String]()
        for i in list{
            json["StudentID"] = i.studentId
            json["StudentName"] = i.studentName
            json["ClassId"] = Common.shared.classId
            json["ClassName"] = ""
            json["SectionId"] = Common.shared.sectionId
            json["SectionName"] = i.section
            json["RollNo"] = i.roll
            json["isChecked"] = "true"
            if i.status.lowercased() == "a"{
                json["isChecked"] = "false"
            }
            jsonArray.append(json)
        }
        let jsonObject = JSON(jsonArray)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.string(from: Date())
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let date1 = dateFormatter.string(from: modifiedDate)
        let finalJson = ["isForAllStudent":JSON("\(isForAllStudent)"),"messageDetail":JSON("\(txtMessage.text ?? "")"),"messageDate":JSON("\(date)"),"messageExpireDate":JSON("\(date1)"),"TeacherId":JSON("\(Common.shared.teacherId)"),"studentList":jsonObject]
        
        fnPostApiWithJson(url: appUrl + "SendMessageToStudents", json: JSON(finalJson), completionHandler: {(res,json)->Void in
            if(res){
                showToast(state:self, message: "Message Sent")
                self.dismiss(animated: true)
            }else{
                showToast(state: self, message: "Error Sending message. Please Try again")
                self.dismiss(animated: true)
            }
        })
    }

}
