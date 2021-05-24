//
//  AssignmentVC.swift
//  MMIHS
//
//  Created by Frost on 4/21/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AssignmentVC: UIViewController {

    @IBOutlet weak var tblAssignment: UITableView!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [Assignment]()
    var dateFormatter = DateFormatter()
    var today = String()
    var daysList = [String]()
    private var datePickerClass:UIDatePicker?
    @IBOutlet weak var dropdownDate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblAssignment.delegate = self
        self.tblAssignment.dataSource = self
        self.tblAssignment.rowHeight = 75
        self.tblAssignment.tableFooterView = UIView()
        datePickerClass = UIDatePicker()
        datePickerClass?.datePickerMode = .date
        datePickerClass?.locale = Locale(identifier: "en_US_POSIX")
        datePickerClass?.calendar = Calendar(identifier: .iso8601)
        datePickerClass?.addTarget(self, action: #selector(dateChanged(datePickerField:)), for: .valueChanged)
        
        if #available(iOS 14, *) {
            datePickerClass!.preferredDatePickerStyle = .wheels
            datePickerClass!.sizeToFit()
        }
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        today = dateFormatter.string(from: Date())
        dropdownDate.inputView = datePickerClass
        dropdownDate.text = today
        
        let imgViewForDropDown = UIImageView(image: UIImage(named: "ic_downarrow"))
        if let size = imgViewForDropDown.image?.size {
            imgViewForDropDown.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            let padding: CGFloat = 10
            let container = UIView(frame: CGRect(x: 0, y: 0, width: size.width + padding, height: size.height))
            container.addSubview(imgViewForDropDown)
            dropdownDate.rightView = container
            dropdownDate.rightViewMode = .always
        }
        
//        for i in 1...7 {
//            let interval = i * -1
//            let date = Calendar.current.date(byAdding: .day, value: interval, to: Date())
//            daysList.append(dateFormatter.string(from: date!))
//        }
        
        fnGetAssignments(url: appUrl + "GetClassHomework?userid=\(Common.shared.userId)&studentid=\(Common.shared.studentId)&date=\(today)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePickerField:UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dropdownDate.text = dateFormatter.string(from: datePickerField.date)
//        view.endEditing(true)
        fnGetAssignments(url: appUrlV2 + "GetClassHomework?userid=\(Common.shared.userId)&studentid=\(Common.shared.studentId)&date=\(dateFormatter.string(from: datePickerField.date))")
    }
    
    func fnGetAssignments(url:String){
        self.list.removeAll()
        showProgressBar(state: self, activityIndicator: activityIndicator)
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
                            if json == []{
//                                showToast(state: self, message: "No Homeworks!")
                            }else{
                                for (index,subJson):(String, JSON) in json {
                                    self.list.append(Assignment(classId: subJson["ClassID"].stringValue, subjectId: subJson["SubjectID"].stringValue, sectionId: subJson["SectionID"].stringValue, subjectName: subJson["SubjectName"].stringValue, homeworkDate: subJson["homeworkDate"].stringValue, homeworkDescription: subJson["HomeworkDescription"].stringValue, teacherId: subJson["TeacherID"].stringValue, teacherName: subJson["TeacherName"].stringValue))
                                }
                            }
                        }else{
                            showToast(state: self, message: "Exception occurred!")
                        }
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblAssignment.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    showToast(state: self, message: "Network error")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
    }
    
}

extension AssignmentVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            tblAssignment.setEmptyMessage("No Assignments.")
        } else {
            tblAssignment.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentViewCell", for: indexPath) as? AssignmentViewCell else{
            return UITableViewCell()
        }
        let obj:Assignment = list[indexPath.row]
        //        cell.textLabel!.text = list[indexPath.row].leaveName
        cell.txtName.text = obj.subjectName
        cell.txtDate.text = obj.homeworkDate
        cell.txtDesc.text = obj.homeworkDescription
        cell.txtAssignee.text = obj.teacherName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd"
        if(obj.homeworkDate != ""){
            cell.txtDay.text = dateFormatter1.string(from: dateFormatter.date(from: obj.homeworkDate) ?? Date())
        }
         cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj:Assignment = list[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "noticeContentVC") as! NoticeContentVC
        VC.noticeTitle = obj.subjectName
        VC.desc = obj.homeworkDescription
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}

