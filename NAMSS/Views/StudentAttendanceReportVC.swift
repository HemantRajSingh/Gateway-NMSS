//
//  StudentAttendanceReportVC.swift
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

class StudentAttendanceReportVC: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tblAttendance: UITableView!
    private var list = [StudentLog]()
    var classList = [SimpleObject]()
    var facultyList = [SimpleObject]()
    var departmentList = [SimpleObject]()
    @IBOutlet weak var datePicker: UITextField!
    private var datePickerClass:UIDatePicker?
    @IBOutlet weak var txtLogDate: UILabel!
    @IBOutlet weak var txtFirstPunched: UILabel!
    @IBOutlet weak var txtLastPunched: UILabel!
    @IBOutlet weak var txtStaff: UILabel!
    @IBOutlet weak var txtPresent: UILabel!
    
    @IBAction func fnLoadData(_ sender: Any) {
        self.displayReport()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAttendance.tableFooterView = UIView()
        tblAttendance.rowHeight = 50
        datePickerClass = UIDatePicker()
        datePickerClass?.datePickerMode = .date
        datePickerClass?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass?.calendar = Calendar(identifier: .iso8601)
        datePickerClass?.addTarget(self, action: #selector(dateChanged(datePickerField:)), for: .valueChanged)
//        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(viewTapped(gestureRecognizer:)))
//        view.addGestureRecognizer(tapGesture)
        
        if #available(iOS 14, *) {
            datePickerClass!.preferredDatePickerStyle = .wheels
            datePickerClass!.sizeToFit()
        }
        
        datePicker.inputView = datePickerClass
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: Date())
        self.displayReport()
    }
    
//    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
//        view.endEditing(true)
//    }
    
    @objc func dateChanged(datePickerField:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: datePickerField.date)
        view.endEditing(true)
    }
    
    func loadData(url:String, completionHandler:@escaping (Bool,[StudentLog]) -> Void){
        var dataList = [StudentLog]()
        dataList.append(StudentLog(serial: "S.No", faculty: "Faculty", program: "Program", year: "Year-Class", presentStudent: [NewStudentLog](), absentStudent: [NewStudentLog]()))
        fnGetApi(url: url, completionHandler: {(res,json)->Void in
            if(res == true){
                var json1 = json["summary"].array ?? [JSON]()
                let studentClasses = json["studentclasses"].array
                let faculties = json["faculties"].array
                let departments = json["departments"].array
                
                if json1.count > 0 {
                    let summary = json1[0].dictionary ?? [String:JSON]()
                    self.txtLogDate.text = summary["LogDate"]?.stringValue ?? ""
                    self.txtFirstPunched.text = summary["FirstPunchedTime"]?.stringValue ?? ""
                    self.txtLastPunched.text = summary["LastPunchedTime"]?.stringValue ?? ""
                    self.txtStaff.text = summary["TotalStaff"]?.stringValue ?? ""
                    self.txtPresent.text = summary["TotalStudent"]?.stringValue ?? ""
                    let studentPresent = summary["StudentPresent"]
                    let studentAbsent = summary["StudentAbsent"]
                    
                    for (index,subJson):(String, JSON) in JSON(faculties) {
                        self.facultyList.append(SimpleObject(id: subJson["FACULTYID"].stringValue, name: subJson["FACULTYNAME"].stringValue))
                    }
                    for (index,subJson):(String, JSON) in JSON(departments) {
                        self.departmentList.append(SimpleObject(id: subJson["DEPARTMENTID"].stringValue, name: subJson["DEPARTMENTNAME"].stringValue))
                    }
                    
                    for (index,subJson):(String, JSON) in JSON(studentClasses) {
                        self.classList.append(SimpleObject(id: subJson["CLASSID"].stringValue, name: subJson["CLASSNAME"].stringValue))
                        let facultyName = self.getFacultyName(id: subJson["FACULTYID"].stringValue)
                        let departmentName = self.getDepartmentName(id: subJson["DEPARTMENTID"].stringValue)
                        let classId = subJson["CLASSID"].stringValue
                        var studentLog = StudentLog(serial: index, faculty: facultyName, program: departmentName, year: subJson["CLASSNAME"].stringValue, presentStudent: [NewStudentLog](), absentStudent: [NewStudentLog]())
                        
                        for (index,subjson):(String, JSON) in JSON(studentPresent) {
                            if classId == subjson["ClassId"].stringValue{
                                studentLog.presentStudent.append(NewStudentLog(id: subjson["StudentId"].stringValue, name: subjson["StudentName"].stringValue, classId: subjson["ClassId"].stringValue, className: subjson["ClassName"].stringValue, depId: subjson["DepartmentId"].stringValue, depName: subjson["DepartmentName"].stringValue, facId: subjson["FacultyId"].stringValue, facName: subjson["FacultyName"].stringValue, mobile: subjson["MobileNo"].stringValue))
                            }
                            
                        }
                        for (index,subjson):(String, JSON) in JSON(studentAbsent) {
                            if classId == subjson["ClassId"].stringValue{
                                studentLog.absentStudent.append(NewStudentLog(id: subjson["StudentId"].stringValue, name: subjson["StudentName"].stringValue, classId: subjson["ClassId"].stringValue, className: subjson["ClassName"].stringValue, depId: subjson["DepartmentId"].stringValue, depName: subjson["DepartmentName"].stringValue, facId: subjson["FacultyId"].stringValue, facName: subjson["FacultyName"].stringValue, mobile: subjson["MobileNo"].stringValue))
                            }
                            
                        }
                        dataList.append(studentLog)
                        
                    }
                }
                
                
                completionHandler(true,dataList)
                
            }else{
                completionHandler(false,dataList)
            }
        })
    }
    
    func getFacultyName(id:String) -> String{
        for i in self.facultyList {
            if(i.id == id){
                return i.name
            }
        }
        return ""
    }
    
    func getDepartmentName(id:String) -> String{
        for i in self.departmentList {
            if(i.id == id){
                return i.name
            }
        }
        return ""
    }
    
    func displayReport(){
        showProgressBar(state: self, activityIndicator: activityIndicator)
        list.removeAll()
        var url:String = appUrl + "GetDeviceAttendanceLog?userid=\(Common.shared.userId)&date=\(datePicker.text ?? "")"
        loadData(url: url, completionHandler: {(status,res) -> Void in
            if(status == true){
                if(res.count > 0){
                    self.list = res
                    self.tblAttendance.reloadData()
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }else{
                    showToast(state:self,message: "No data available")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
            }else{
                showToast(state:self,message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    
    
    
}

extension StudentAttendanceReportVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "studentLogViewCell", for:indexPath) as? StudentLogViewCell else{
            return UITableViewCell()
        }
        let obj:StudentLog = list[indexPath.row]
        cell.txtSerial.text = obj.serial
        cell.txtFaculty.text = obj.faculty
        cell.txtProgram.text = obj.program
        cell.txtClass.text = obj.year
        if obj.faculty == "Faculty" {
            cell.backgroundView?.backgroundColor = UIColor.blue
//            cell.txtSerial.font = UIFont.boldSystemFont(ofSize: 12)
//            cell.txtFaculty.font = UIFont.boldSystemFont(ofSize: 12)
//            cell.txtProgram.font = UIFont.boldSystemFont(ofSize: 12)
//            cell.txtClass.font = UIFont.boldSystemFont(ofSize: 12)
//            cell.txtPresent.font = UIFont.boldSystemFont(ofSize: 12)
//            cell.txtAbsent.font = UIFont.boldSystemFont(ofSize: 12)
            cell.txtPresent.text = "Present"
            cell.txtAbsent.text = "Absent"
        }else{
            cell.txtPresent.text = String(obj.presentStudent.count)
            cell.txtAbsent.text = String(obj.absentStudent.count)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let obj = list[indexPath.row].absentStudent
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "absentPopUpVC") as! AbsentPopUpVC
        VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        VC.list = obj
        self.addChild(VC)
        self.view.addSubview(VC.view)
        
    }
    
}
