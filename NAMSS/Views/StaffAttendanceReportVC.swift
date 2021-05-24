//
//  StaffAttendanceReportVC.swift
//  MMIHS
//
//  Created by Frost on 3/24/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import WebKit
import DLRadioButton
import SwiftyJSON

class StaffAttendanceReportVC: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var datePicker: UITextField!
    @IBOutlet weak var dropdownFaculty: UITextField!
    @IBOutlet weak var dropdownDepartment: UITextField!
    var list = [Staff]()
    @IBOutlet weak var tblStaffAttendance: UITableView!
    var status = "", departmentId = "", designationId = ""
    @IBAction func present(_ sender: Any) {
        status = "present"
    }
    @IBAction func absent(_ sender: Any) {
        status = "absent"
    }
    @IBAction func leave(_ sender: Any) {
        status = "leave"
    }
    
    @IBAction func fnLoadData(_ sender: Any) {
        displayReport()
    }
    
    let options = ["1","2","3"]
    private var datePickerClass:UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblStaffAttendance.tableFooterView = UIView()
        self.tblStaffAttendance.rowHeight = 85
        datePickerClass = UIDatePicker()
        datePickerClass?.datePickerMode = .date
        datePickerClass?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass?.calendar = Calendar(identifier: .iso8601)
        datePickerClass?.addTarget(self, action: #selector(StaffAttendanceReportVC.dateChanged(datePickerField:)), for: .valueChanged)
//        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(StaffAttendanceReportVC.viewTapped(gestureRecognizer:)))
//        view.addGestureRecognizer(tapGesture)
        
        if #available(iOS 14, *) {
            datePickerClass!.preferredDatePickerStyle = .wheels
            datePickerClass!.sizeToFit()
        }
        
        datePicker.inputView = datePickerClass
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: Date())
        showProgressBar(activityIndicator: self.activityIndicator)
        self.loadDepartment()
        self.loadDesignation()
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
    }
    
    func hideProgressBar(activityIndicator:UIActivityIndicatorView){
        activityIndicator.stopAnimating()
    }
    
    func loadDepartment(){
        var dList = [SimpleObject]()
        dList.append(SimpleObject(id: "", name: "All"))
        fnGetApi(url: appUrl + "GetStaffDepartment?userid=\(Common.shared.userId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    dList.append(SimpleObject(id: subJson["DepartmentID"].stringValue, name: subJson["Department"].stringValue))
                }
                self.dropdownFaculty.loadDropdownData(data: dList, type:"faculty", completionHandler: {(res) in
                    self.departmentId = res.id
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadDesignation(){
        var dapartmentList = [SimpleObject]()
        dapartmentList.append(SimpleObject(id: "", name: "All"))
        fnGetApi(url: appUrl + "GetDesignations?userid=\(Common.shared.userId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (index,subJson):(String, JSON) in json {
                    dapartmentList.append(SimpleObject(id: subJson["DesignationID"].stringValue, name: subJson["DesignationName"].stringValue))
                }
                self.dropdownDepartment.loadDropdownData(data: dapartmentList, type:"department", completionHandler: {(res) in
                    self.designationId = res.id
                    self.hideProgressBar(activityIndicator: self.activityIndicator)
                    self.displayReport()
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadData(url:String, completionHandler:@escaping (Bool,[Staff]) -> Void){
        var dataList = [Staff]()
        fnGetApi(url: url, completionHandler: {(res,json)->Void in
            if(res == true){
                var deviceLogArray = json["deviceLog"]
                var log = json["loggedInStaffDetail"]
                if self.status == "absent"{
                    log = json["notLoggedInStaffDetail"]
                }
                if self.status == "leave"{
                    log = json["staffLeaveRecord"]
                }
                var staffId,staffCode,staffName,staffRank,attendanceId,designationId,designationName,departmentId,department,mobile,staffShiftId,shiftName,startTime,endTime:String
                for (index,subJson):(String, JSON) in log {
                    staffId = subJson["StaffID"].stringValue
                    staffCode = subJson["StaffCode"].stringValue
                    staffName = subJson["StaffName"].stringValue
                    staffRank = subJson["StaffRank"].stringValue
                    attendanceId = subJson["AttendanceId"].stringValue
                    designationId = subJson["DesignationID"].stringValue
                    designationName = subJson["DesignationName"].stringValue
                    departmentId = subJson["DepartmentID"].stringValue
                    department = subJson["Department"].stringValue
                    mobile = subJson["MobileNo"].stringValue
                    staffShiftId = subJson["StaffShiftId"].stringValue
                    shiftName = subJson["ShiftName"].stringValue
                    startTime = subJson["StartTime"].stringValue
                    endTime = subJson["EndTime"].stringValue
                    var deviceLog = [String]()
                    for (index,subjson):(String, JSON) in deviceLogArray {
                        if attendanceId == subjson["UserId"].stringValue {
                            deviceLog.append(subjson["LogDateTime"].stringValue)
                        }
                    }
                    dataList.append(Staff(staffId: staffId, staffCode: staffCode, staffName: staffName, staffRank: staffRank, attendanceId: attendanceId, designationId: designationId, designationName: designationName, departmentId: departmentId, department: department, mobile: mobile, staffShiftId: staffShiftId, shiftName: shiftName, startTime: startTime, endTime: endTime, deviceLog: deviceLog))
                }
                completionHandler(true,dataList)
                
            }else{
                completionHandler(false,dataList)
            }
        })
    }
    
    func displayReport(){
        self.showProgressBar(activityIndicator: activityIndicator)
        list.removeAll()
        let url:String = appUrl + "GetStaffAttendanceRecord?userId=\(Common.shared.userId)&attendanceDate=\(datePicker.text ?? "")&DepartmentId=\(self.departmentId)&DesignationId=\(self.designationId)"
        loadData(url: url, completionHandler: {(status,res) -> Void in
            if(status == true){
                if(res.count > 0){
                    self.list = res
                    self.tblStaffAttendance.reloadData()
                    self.hideProgressBar(activityIndicator: self.activityIndicator)
                }else{
                    NAMSS.showToast(state:self,message: "No data available")
                    self.hideProgressBar(activityIndicator: self.activityIndicator)
                }
            }else{
                NAMSS.showToast(state:self,message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
//            if(status == true){
//                if(res.count > 0){
//                    if let path = Bundle.main.path(forResource: "bootstrap.min", ofType: "css"){
//                        var html = """
//                    <html><head><link rel='stylesheet' type='text/css' href='%@'><style>table td,table th{font-size: 30px !important; text-align : left;}</style></head><body><table class="table table-striped"><thead><tr><th scope="col">#</th><th scope="col">Staff Name</th><th scope="col">In</th><th scope="col">Out</th><th scope="col">Hour</th><th scope="col">Remarks</th></tr></thead><tbody>
//                    """;
//                        for items in res{
//                            let staffId = items.staffId;
//                            let staffName = items.staffName;
//                            let staffStartTime = items.startTime;
//                            let staffEndTime = items.endTime;
//                            let staffShiftName = items.shiftName;
//                            let staffDesignationName = items.designationName;
//                            html += "<tr><td>"+staffId+"</td>";
//                            html += "<td>"+staffName+"</td>";
//                            html += "<td>"+staffStartTime+"</td>";
//                            html += "<td>"+staffEndTime+"</td>";
//                            html += "<td>"+staffShiftName+"</td>";
//                            html += "<td>"+staffDesignationName+"</td></tr>";
//                        }
//                        html += """
//                        </tbody></table></body></html>
//                        """;
//
//                        html = String(format: html, path)
//                        html = html.replacingOccurrences(of: "\n", with: "")
//                        print(html)
//                        let baseUrl = URL(fileURLWithPath: path)
//                        self.webView.loadHTMLString(html, baseURL: baseUrl)
//                        self.hideProgressBar(activityIndicator: self.activityIndicator)
//                    }
//                }else{
//                    self.webView.loadHTMLString("", baseURL: nil)
//                    self.hideProgressBar(activityIndicator: self.activityIndicator)
//                    self.showToast(message: "No data available")
//                }
//            }else{
//                self.webView.loadHTMLString("", baseURL: nil)
//                self.showToast(message: "Something error")
//                self.hideProgressBar(activityIndicator: self.activityIndicator)
//            }
        })
    }
    
}

extension UITextField{
    func loadDropdownData(data : [SimpleObject], type:String, completionHandler:@escaping ((SimpleObject)->Void)){
        self.inputView = MyPickerView(pickerData: data, dropdownField: self, type:type, completionHandler:{(SimpleObject) -> Void in
            completionHandler(SimpleObject);
            })
    }
}

extension StaffAttendanceReportVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "staffAttendanceViewCell", for:indexPath) as? StaffAttendanceViewCell else{
            return UITableViewCell()
        }
        let obj:Staff = list[indexPath.row]
        let logList = obj.deviceLog
        cell.txtTime.text = ""
        if(logList.count > 1){
            var checkOut = logList[logList.count - 1].split(separator: " ")
            let endTime = " - Check Out : " + String(checkOut[1])
            var checkIn = logList[0].split(separator: " ")
            
            cell.txtTime.text = "Check In : " + checkIn[1] + endTime
        }
        cell.txtName.text = obj.staffName
        cell.txtDepartment.text = obj.department
        cell.txtDesignation.text = obj.designationName
        cell.txtShift.text = obj.shiftName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let obj = list[indexPath.row].deviceLog
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "absentPopUpVC") as! AbsentPopUpVC
        VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        VC.list1 = obj
        VC.txtTitle.text = "Device Logs"
        self.addChild(VC)
        self.view.addSubview(VC.view)
        
    }
    
}
