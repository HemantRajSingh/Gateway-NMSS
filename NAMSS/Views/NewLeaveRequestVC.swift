//
//  NewLeaveRequestVC.swift
//  MMIHS
//
//  Created by Frost on 4/12/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NewLeaveRequestVC: UIViewController {

    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet weak var pickerLeaveType: UITextField!
    @IBOutlet weak var txtLeaveDesc: UITextView!
    @IBOutlet weak var datePickerFrom: UITextField!
    @IBOutlet weak var datePickerTo: UITextField!
    
    private var datePickerClass1:UIDatePicker?
    private var datePickerClass2:UIDatePicker?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var leaveTypeId = "0"
    let date = Date()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.requestLeave(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        txtLeaveDesc.layer.borderColor = UIColor.black.cgColor
        txtLeaveDesc.layer.borderWidth = 1
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePickerClass1 = UIDatePicker()
        datePickerClass1?.datePickerMode = .date
        datePickerClass1?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass1?.calendar = Calendar(identifier: .iso8601)
        datePickerClass1?.addTarget(self, action: #selector(fromDateChanged(datePickerField:)), for: .valueChanged)
        datePickerClass2 = UIDatePicker()
        datePickerClass2?.datePickerMode = .date
        datePickerClass2?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass2?.calendar = Calendar(identifier: .iso8601)
        datePickerFrom.text = dateFormatter.string(from: Date())
        datePickerTo.text = dateFormatter.string(from: Date())
        datePickerClass2?.addTarget(self, action: #selector(toDateChanged(datePickerField:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        if #available(iOS 14, *) {
            datePickerClass1!.preferredDatePickerStyle = .wheels
            datePickerClass1!.sizeToFit()
            datePickerClass2!.preferredDatePickerStyle = .wheels
            datePickerClass2!.sizeToFit()
        }
        
        datePickerFrom.inputView = datePickerClass1
        datePickerTo.inputView = datePickerClass2
        
        showProgressBar(state: self, activityIndicator: activityIndicator)
        loadLeaveTypes()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollview.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
    }
    
    @objc func requestLeave(sender: UIBarButtonItem){
        var jsonArray = [Dictionary<String, String>]()
        var json = [String:String]()
        json["StaffId"] = Common.shared.staffId
        json["LeaveTypeId"] = leaveTypeId
        json["RequestDate"] = dateFormatter.string(from: date)
        json["LeaveDateFrom"] = datePickerFrom.text
        json["LeaveDateTo"] = datePickerTo.text
        let d1:Date = dateFormatter.date(from: datePickerFrom.text!)!
        let d2:Date = dateFormatter.date(from: datePickerTo.text!)!
        var days = ""
        days = String(Int(d2.timeIntervalSince(d1) / 86400))
        if(datePickerFrom.text! == datePickerTo.text!){
            days = "1"
        }
        json["LeaveTotalDays"] = days
        json["LeaveRemainedDays"] = days
        json["Remarks"] = txtLeaveDesc.text
        jsonArray.append(json)
        
        fnPostApiWithJson(url: appUrl + "SaveStaffLeaveRequest", json: JSON(jsonArray), completionHandler: {(res,json)->Void in
            if(res){
                showToast(state: self, message: "Leave Requested")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                showToast(state: self, message: "Error Requesting Leave. Please Try again")
            }
        })
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func fromDateChanged(datePickerField:UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePickerFrom.text = dateFormatter.string(from: datePickerField.date)
        view.endEditing(true)
    }
    
    @objc func toDateChanged(datePickerField:UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePickerTo.text = dateFormatter.string(from: datePickerField.date)
        view.endEditing(true)
    }
    
    func loadLeaveTypes(){
        var leaveTypes = [SimpleObject]()
        fnGetApi(url: appUrl + "GetLeaveType?memberTypeId=\(Common.shared.memberTypeId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    leaveTypes.append(SimpleObject(id: subJson["LeaveTypeId"].stringValue, name: subJson["LeaveName"].stringValue))
                }
                self.pickerLeaveType.loadDropdownData(data: leaveTypes, type:"", completionHandler: {(leave) -> Void in
                    self.leaveTypeId = leave.id
                })
                hideProgressBar(activityIndicator: self.activityIndicator)
            }else{
                showToast(state:self,message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }

}

extension NewLeaveRequestVC : UITextFieldDelegate, UIPickerViewDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
