//
//  AddNewAssignmentVC.swift
//  MMIHS
//
//  Created by Frost on 4/21/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddNewAssignmentVC: UIViewController {

    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var subjectName = String()
    let dateFormatter = DateFormatter()
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDesc: UITextView!
    @IBAction func btnSubmit(_ sender: Any) {
        self.view.endEditing(true)
        postAssignment()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtTitle.text = subjectName
        txtDesc.layer.borderWidth = 1
        txtDesc.layer.borderColor = UIColor.gray.cgColor
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(StaffAttendanceReportVC.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func postAssignment(){
        var jsonArray = [Dictionary<String, String>]()
        var json = [String:String]()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.string(from: Date())
        json["ClassId"] = Common.shared.classId
        json["SectionId"] = Common.shared.sectionId
        json["SubjectId"] = Common.shared.subjectId
        json["SubjectName"] = txtTitle.text ?? ""
        json["HomeWorkDate"] = date
        json["HomeWorkDescription"] = txtDesc.text ?? ""
        json["TeacherId"] = Common.shared.teacherId
        jsonArray.append(json)
        
        fnPostApiWithJson(url: appUrl + "SaveClassHomeWork", json: JSON(jsonArray), completionHandler: {(res,json)->Void in
            if(res){
                showToast(state: self, message: "Assignment Added")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                showToast(state: self, message: "Error Adding Assignment. Please Try again")
            }
        })
    }

}
