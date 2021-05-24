//
//  AttendanceVC.swift
//  MMIHS
//
//  Created by Frost on 4/7/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

import UIKit
import WebKit
import DLRadioButton
import SwiftyJSON

class AttendanceVC: UIViewController {
    
    @IBOutlet weak var tblAttendance: UITableView!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var list = [Student]()
    @IBOutlet weak var datePicker: UITextField!
    @IBOutlet weak var dropdownFaculty: UITextField!
    @IBOutlet weak var dropdownDepartment: UITextField!
    @IBOutlet weak var dropdownClass: UITextField!
    @IBOutlet weak var dropdownSection: UITextField!
    @IBOutlet weak var dropdownPeriod: UITextField!
    @IBOutlet weak var dropdownSubject: UITextField!
    var periodId = "",subjectId = "",sectionId = "",classId = "",facultyId="",departmentId = ""
    var status = ""
    private var datePickerClass:UIDatePicker?
    
    @IBAction func fnLoadData(_ sender: Any) {
        view.endEditing(true)
        list.removeAll()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if(periodId == ""){
            periodId = "0"
        }
        let url:String = appUrl + "GetClassWiseDaillyAttendanceRecord?classid=\(self.classId)&sectionid=\(self.sectionId)&staffUserId=\(Common.shared.userId)&date=\(datePicker.text ?? dateFormatter.string(from: Date()))&periodid=\(periodId)"
        loadData(url: url, completionHandler: {(status,res) -> Void in
            if(status == true){
                if(res.count > 0){
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.list = res
                } else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.list = []
                    self.showToast(message: "No any records found!")
                }
                self.tblAttendance.reloadData()
            }else{
                self.tblAttendance.reloadData()
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.submitForAttendance(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        tblAttendance.delegate = self
        tblAttendance.dataSource = self
        tblAttendance.tableFooterView = UIView()
        tblAttendance.rowHeight = 40
        datePickerClass = UIDatePicker()
        datePickerClass?.datePickerMode = .date
        datePickerClass?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass?.calendar = Calendar(identifier: .iso8601)
        datePickerClass?.addTarget(self, action: #selector(StaffAttendanceReportVC.dateChanged(datePickerField:)), for: .valueChanged)
        
        if #available(iOS 14, *) {
            datePickerClass!.preferredDatePickerStyle = .wheels
            datePickerClass!.sizeToFit()
        }
        
        datePicker.inputView = datePickerClass
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: Date())
        
        showProgressBar(activityIndicator: self.activityIndicator)
        self.loadFaculty()
//        self.loadDepartment()
        hideProgressBar(activityIndicator: self.activityIndicator)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePickerField:UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: datePickerField.date)
        view.endEditing(true)
    }
    
    @objc func back(sender: UIBarButtonItem){
        openView(state: self, viewName: "DashboardVC")
    }
    
    @objc func submitForAttendance(sender: UIBarButtonItem){
        self.fnDoAttendance()
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
    
    func showProgressBar(activityIndicator:UIActivityIndicatorView){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideProgressBar(activityIndicator:UIActivityIndicatorView){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func loadFaculty(){
        var facultyList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetFaculty", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    facultyList.append(SimpleObject(id: subJson["FACULTYID"].stringValue, name: subJson["FACULTYNAME"].stringValue))
                }
                self.dropdownFaculty.loadDropdownData(data: facultyList, type:"faculty", completionHandler: {(res) in
                    self.facultyId = res.id
                    self.loadDepartment()
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadDepartment(){
        var dapartmentList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetDepartment", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    dapartmentList.append(SimpleObject(id: subJson["DEPARTMENTID"].stringValue, name: subJson["DEPARTMENTNAME"].stringValue))
                }
                self.dropdownDepartment.loadDropdownData(data: dapartmentList, type:"department", completionHandler: {(res) in
                    self.departmentId = res.id
                    self.loadClass()
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadClass(){
        var classList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetClassLists?facultyid=\(self.facultyId)&departmentId=\(self.departmentId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    classList.append(SimpleObject(id: subJson["CLASSID"].stringValue, name: subJson["CLASSNAME"].stringValue))
                }
                self.dropdownClass.loadDropdownData(data: classList, type:"class", completionHandler: {(res) in
                    self.classId = res.id
                    self.loadSection()
                    self.loadPeriod()
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadSection(){
        var sectionList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetSectionByClass?classid=\(self.classId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    sectionList.append(SimpleObject(id: subJson["SECTIONID"].stringValue, name: subJson["SECTIONNAME"].stringValue))
                }
                self.dropdownSection.loadDropdownData(data: sectionList, type:"section", completionHandler: {(res) in
                    self.sectionId = res.id
                    self.loadSubject()
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadPeriod(){
        var periodList = [SimpleObject]()
        periodList.append(SimpleObject(id: "", name: "Select"))
        periodList.append(SimpleObject(id: "1", name: "First"))
        periodList.append(SimpleObject(id: "2", name: "Second"))
        periodList.append(SimpleObject(id: "3", name: "Third"))
        periodList.append(SimpleObject(id: "4", name: "Fourth"))
        periodList.append(SimpleObject(id: "5", name: "Fifth"))
        periodList.append(SimpleObject(id: "6", name: "Sixth"))
        periodList.append(SimpleObject(id: "7", name: "Seventh"))
        periodList.append(SimpleObject(id: "8", name: "Eighth"))
        periodList.append(SimpleObject(id: "9", name: "Ninth"))
        periodList.append(SimpleObject(id: "10", name: "Tenth"))
        self.dropdownPeriod.loadDropdownData(data: periodList, type:"section", completionHandler: {(res) in
                                self.periodId = res.id
                            })
//        fnGetApi(url: appUrl + "GetPeriodList?classid=\(self.classId)&userid=\(Common.shared.userId)", completionHandler: {(res,json)->Void in
//            if(res == true){
//                for (index,subJson):(String, JSON) in json {
//                    sectionList.append(SimpleObject(id: subJson["ClassId"].stringValue, name: subJson["CLASSNAME"].stringValue))
//                }
//                self.dropdownPeriod.loadDropdownData(data: sectionList, type:"section", completionHandler: {(res) in
//                    self.periodId = res.id
//                    self.loadSubject()
//                })
//            }else{
//                self.showToast(message: "Something error")
//                self.hideProgressBar(activityIndicator: self.activityIndicator)
//            }
//        })
    }
    
    func loadSubject(){
        var sectionList = [SimpleObject]()
        sectionList.append(SimpleObject(id: "", name: "Select"))
        fnGetApi(url: appUrl + "GetSubjectList?facultyid=\(self.facultyId)&departmentid=\(self.departmentId)&classid=\(self.classId)&sectionid=\(self.sectionId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    sectionList.append(SimpleObject(id: subJson["SubjectId"].stringValue, name: subJson["SubjectName"].stringValue))
                }
                self.dropdownSubject.loadDropdownData(data: sectionList, type:"section", completionHandler: {(res) in
                    self.subjectId = res.id
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadData(url:String, completionHandler:@escaping (Bool,[Student]) -> Void){
        var dataList = [Student]()
        fnPostApi(url: url, completionHandler: {(res,json)->Void in
            if(res == true){
                var studentId,studentName,section,roll,date,status,staffId,staffName:String
                for (index,subJson):(String, JSON) in json {
                    studentId = subJson["StudentId"].stringValue
                    studentName = subJson["StudentName"].stringValue
                    section = subJson["Section"].stringValue
                    roll = subJson["RollNo"].stringValue
                    date = subJson["Date"].stringValue
                    status = subJson["Status"].stringValue
                    if(status.lowercased() != "p"){
                        status = "A"
                    }
                    staffId = subJson["StaffId"].stringValue
                    staffName = subJson["StaffName"].stringValue
                    dataList.append(Student(studentId: studentId, studentName: studentName, section: section, roll: roll, date: date, status: status, staffId: staffId, staffName: staffName))
                }
                completionHandler(true,dataList)
                
            }else{
                completionHandler(false,dataList)
            }
        })
    }
    
    func fnDoAttendance(){
        var jsonArray = [Dictionary<String, String>]()
        var json = [String:String]()
        for i in list{
            json["StudentID"] = i.studentId
            json["AttendanceStatus"] = i.status
            jsonArray.append(json)
        }
        let jsonObject = JSON(jsonArray)
        let date:String = datePicker.text ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: Date())
        var finalJson = [String:JSON]()
        if(self.periodId != "0"){
            finalJson = ["AttendanceDateAD":JSON("\(date)"),"ClassID":JSON("\(self.classId)"),"SectionID":JSON("\(self.sectionId)"),"IsAllPresent":"false","TeacherId":JSON("\(Common.shared.staffId)"),"PeriodId":JSON("\(self.periodId)"),"SubjectId":JSON("\(self.subjectId)"),"AttendanceTime":JSON("\(time)"),"StudentAttendanceStatus":jsonObject]
        }else{
            finalJson = ["AttendanceDateAD":JSON("\(date)"),"ClassID":JSON("\(self.classId)"),"SectionID":JSON("\(self.sectionId)"),"IsAllPresent":"false","TeacherId":JSON("\(Common.shared.staffId)"),"PeriodId":JSON(""),"SubjectId":JSON(""),"AttendanceTime":JSON("\(time)"),"StudentAttendanceStatus":jsonObject]
        }
        
        fnPostApiWithJson(url: appUrl + "SaveAttendance", json: JSON(finalJson), completionHandler: {(res,json)->Void in
            if(res){
//                MMIHS.showToast(state: AttendanceVC(), message: "Attendance Done")
                NAMSS.showToast(state:self, message: "Attendance Done")
                self.list.removeAll()
                self.tblAttendance.reloadData()
                self.navigationItem.rightBarButtonItem?.isEnabled = false
//                openView(state: self, viewName: "attendanceVC")
            }else{
                NAMSS.showToast(state: self, message: "Something error occurred. Please try again!")
            }
        })
        
    }
    
    
    @IBAction func `switch`(_ sender: Any) {
        let switchInCell:UISwitch = sender as! UISwitch
        let cell = switchInCell.superview?.superview as! UITableViewCell
        let row = tblAttendance.indexPath(for: cell)!
        if(switchInCell.isOn){
            list[row.row].status = "p"
        }else{
            list[row.row].status = "A"
        }
    }
    
}

extension AttendanceVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "attendanceViewCell", for:indexPath) as? AttendanceViewCell else{
            return UITableViewCell()
        }
        cell.txtName.text = list[indexPath.row].studentName
        if(list[indexPath.row].status.lowercased() == "p"){
            cell.switchPresent.setOn(true, animated: false)
        }else{
            cell.switchPresent.setOn(false, animated: false)
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "attendanceViewCell", for: indexPath) as? AttendanceViewCell
//        let row = indexPath.row
//        if((cell?.switchPresent.isOn)!){
//            cell?.switchPresent.setOn(false, animated: true)
//            list[row].status = "A"
//        }else{
//            cell?.switchPresent.setOn(true, animated: true)
//            list[row].status = "p"
//        }
//    }
    
}
