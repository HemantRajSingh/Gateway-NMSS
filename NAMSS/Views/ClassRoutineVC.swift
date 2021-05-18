//
//  ClassRoutineVC.swift
//  MMIHS
//
//  Created by Frost on 3/30/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ClassRoutineVC: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var datePicker: UITextField!
    @IBOutlet weak var dropdownFaculty: UITextField!
    @IBOutlet weak var dropdownDepartment: UITextField!
    @IBOutlet weak var dropdownClass: UITextField!
    @IBOutlet weak var dropdownSection: UITextField!
    private var datePickerClass:UIDatePicker?
    private var list = [ClassRoutine]()
    @IBOutlet weak var tblClassRoutine: UITableView!
    var departmentId = "", facultyId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Class Routine"
        tblClassRoutine.delegate = self
        tblClassRoutine.dataSource = self
        tblClassRoutine.rowHeight = 60
        tblClassRoutine.tableFooterView = UIView()
        datePickerClass = UIDatePicker()
        datePickerClass?.datePickerMode = .date
        datePickerClass?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass?.calendar = Calendar(identifier: .iso8601)
        datePickerClass?.addTarget(self, action: #selector(StaffAttendanceReportVC.dateChanged(datePickerField:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(StaffAttendanceReportVC.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        datePicker.inputView = datePickerClass
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        datePicker.text = dateFormatter.string(from: Date())
        self.loadFaculty()
        self.loadDepartment()
        
    }
    
    
    @IBAction func btnLoad(_ sender: Any) {
        fnDownloadClassRoutine()
    }
    
    func openView(viewName:String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: viewName)
        self.navigationController?.pushViewController(VC, animated: true)
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
        self.showProgressBar(activityIndicator: self.activityIndicator)
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
                    Common.shared.classId = res.id
                    self.loadSection()
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
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
                    self.hideProgressBar(activityIndicator: self.activityIndicator)
                    self.fnDownloadClassRoutine()
                })
            }else{
                self.showToast(message: "Something error")
                self.hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func fnDownloadClassRoutine(){
        self.list.removeAll()
        let url = appUrl + "GetClassPeriod?classid=\(Common.shared.classId)&sectionid=\(Common.shared.sectionId)&date=\(datePicker.text ?? "")&userid=\(Common.shared.userId)"
        showProgressBar(activityIndicator: self.activityIndicator)
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
                            var classId,className,periodId,periodName,startTime,endTime,staffId,staffName,date : String
                            
                            for (index,subJson):(String, JSON) in json {
                                classId = subJson["ClassId"].stringValue
                                className = subJson["CLASSNAME"].stringValue
                                periodId = subJson["PeriodId"].stringValue
                                periodName = subJson["PeriodName"].stringValue
                                startTime = subJson["StartTime"].stringValue
                                endTime = subJson["EndTime"].stringValue
                                staffId = subJson["StaffId"].stringValue
                                staffName = subJson["StaffId"].stringValue
                                date = subJson["Date"].stringValue
                                self.list.append(ClassRoutine(classId: classId, className: className, periodId: periodId, periodName: periodName, startTime: startTime, endTime: endTime, staffId: staffId, staffName: staffName, date: date))
                            }
                        }else{
                            NAMSS.showToast(state: self, message: "Exception occurred!")
                        }
                        
//                        if(self.list.count == 0){
//                            self.showToast(message: "Class Routine Empty!")
//                        }

                        self.hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblClassRoutine.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    self.showToast(message: "Network Failure. Please try again!")
                    self.hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
    }
    
    func showProgressBar(activityIndicator:UIActivityIndicatorView){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
//        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideProgressBar(activityIndicator:UIActivityIndicatorView){
        activityIndicator.stopAnimating()
//        UIApplication.shared.endIgnoringInteractionEvents()
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

}

extension ClassRoutineVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            self.tblClassRoutine.setEmptyMessage("")
        } else {
            self.tblClassRoutine.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "classRoutineCell", for: indexPath) as? ClassRoutineViewCell else{
            return UITableViewCell()
        }
        let obj:ClassRoutine = list[indexPath.row]
        cell.txtTime.text = obj.startTime + "-" + obj.endTime
        cell.txtName.text = obj.periodName
        cell.txtStaffName.text = "Teacher : " + obj.staffName
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

}
