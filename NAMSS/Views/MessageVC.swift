//
//  MessageVC.swift
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

class MessageVC: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tblAttendance: UITableView!
    private var list = [Student]()
    private var messageList = [Student]()
    @IBOutlet weak var datePicker: UITextField!
    @IBOutlet weak var dropdownFaculty: UITextField!
    @IBOutlet weak var dropdownDepartment: UITextField!
    @IBOutlet weak var dropdownClass: UITextField!
    @IBOutlet weak var dropdownSection: UITextField!
    var status = "", facultyId = "", departmentId = ""
    private var datePickerClass:UIDatePicker?
    @IBOutlet weak var switchForAll: UISwitch!
    
    
    @IBAction func fnLoadData(_ sender: Any) {
        self.displayReport()
    }
    @IBAction func switchForAll(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAttendance.tableFooterView = UIView()
        tblAttendance.rowHeight = 35
        datePickerClass = UIDatePicker()
        datePickerClass?.datePickerMode = .date
        datePickerClass?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass?.calendar = Calendar(identifier: .iso8601)
        datePickerClass?.addTarget(self, action: #selector(dateChanged(datePickerField:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        datePicker.inputView = datePickerClass
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: Date())
        self.loadFaculty()
        self.loadDepartment()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let popup = segue.destination as! SendMessageVC
        if self.switchForAll.isOn{
            popup.isForAllStudent = "true"
        }else{
            if(self.messageList.count > 0){
                popup.list = self.messageList
            }
        }
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePickerField:UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: datePickerField.date)
        view.endEditing(true)
    }
    
    func loadFaculty(){
        showProgressBar(state:self,activityIndicator: self.activityIndicator)
        var facultyList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetFaculty", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    facultyList.append(SimpleObject(id: subJson["FACULTYID"].stringValue, name: subJson["FACULTYNAME"].stringValue))
                }
                self.dropdownFaculty.loadDropdownData(data: facultyList, type:"faculty", completionHandler: {(res) in
                    self.facultyId = res.id
                })
            }else{
                showToast(state:self,message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
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
                showToast(state:self,message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
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
                    Common.shared.classId = res.id
                    self.loadSection()
                })
            }else{
                showToast(state:self,message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadSection(){
        var sectionList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetSectionByClass?classid=\(Common.shared.classId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    sectionList.append(SimpleObject(id: subJson["SECTIONID"].stringValue, name: subJson["SECTIONNAME"].stringValue))
                }
                self.dropdownSection.loadDropdownData(data: sectionList, type:"section", completionHandler: {(res) in
                    Common.shared.sectionId = res.id
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    self.displayReport()
                })
            }else{
                showToast(state:self,message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
                self.displayReport()
            }
        })
    }
    
    func loadData(url:String, completionHandler:@escaping (Bool,[Student]) -> Void){
        var dataList = [Student]()
        fnPostApi(url: url, completionHandler: {(res,json)->Void in
            if(res == true){
                var studentId,studentName,section,roll,date,status,staffId,staffName:String
                if json["MessageDetail"].stringValue == ""{
                    for (index,subJson):(String, JSON) in json {
                        studentId = subJson["StudentId"].stringValue
                        studentName = subJson["StudentName"].stringValue
                        section = subJson["Section"].stringValue
                        roll = subJson["RollNo"].stringValue
                        date = subJson["Date"].stringValue
//                        status = subJson["Status"].stringValue
//                        if(status.lowercased() != "p"){
                            status = "A"
//                        }
                        staffId = subJson["StaffId"].stringValue
                        staffName = subJson["StaffName"].stringValue
                        dataList.append(Student(studentId: studentId, studentName: studentName, section: section, roll: roll, date: date, status: status, staffId: staffId, staffName: staffName))
                    }
                    completionHandler(true,dataList)
                }else{
                    completionHandler(false,dataList)
                }
                
            }else{
                completionHandler(false,dataList)
            }
        })
    }
    
    @IBAction func `switch`(_ sender: Any) {
        self.switchForAll.setOn(false, animated: true)
        let switchInCell:UISwitch = sender as! UISwitch
        let cell = switchInCell.superview?.superview as! UITableViewCell
        let row = tblAttendance.indexPath(for: cell)!
        if(switchInCell.isOn){
            list[row.row].status = "p"
        }else{
            list[row.row].status = "A"
        }
        self.messageList.append(list[row.row])
    }
    
    func displayReport(){
        showProgressBar(state: self, activityIndicator: activityIndicator)
        list.removeAll()
        var url:String = appUrl + "GetClassWiseDaillyAttendanceRecord?classid=\(Common.shared.classId)&sectionid=\(Common.shared.sectionId)&staffUserId=\(Common.shared.userId)&date=\(datePicker.text ?? "")&periodid=0"
        loadData(url: url, completionHandler: {(status,res) -> Void in
            if(status == true){
                if(res.count > 0){
                    self.list = res
                    self.tblAttendance.reloadData()
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }else{
                    showToast(state:self,message: "No data available")
                    self.tblAttendance.reloadData()
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
            }else{
                showToast(state:self,message: "Something error")
                self.tblAttendance.reloadData()
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
}

extension MessageVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageStudentViewCell", for:indexPath) as? MessageStudentViewCell else{
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
    
}
