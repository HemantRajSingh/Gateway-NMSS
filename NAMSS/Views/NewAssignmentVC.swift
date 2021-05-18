//
//  NewAssignmentVC.swift
//  MMIHS
//
//  Created by Frost on 4/21/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewAssignmentVC: UIViewController {

    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [SimpleObject]()
    
    @IBOutlet weak var tblSubject: UITableView!
    @IBOutlet weak var dropdownFaculty: UITextField!
    @IBOutlet weak var dropdownDepartment: UITextField!
    @IBOutlet weak var dropdownClass: UITextField!
    @IBOutlet weak var dropdownSection: UITextField!
    var facultyId = "",departmentId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblSubject.delegate = self
        self.tblSubject.dataSource = self
        self.tblSubject.tableFooterView = UIView()
        self.loadFaculty()
        self.loadDepartment()
    }
    
    @IBAction func btnLoad(_ sender: Any) {
        view.endEditing(true)
        fnDisplaySubjectList()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
                    self.fnDisplaySubjectList()
                })
            }else{
                showToast(state:self,message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func fnDisplaySubjectList(){
        self.list.removeAll()
        let url = appUrl + "GetSubjectList?facultyid=\(self.facultyId)&departmentid=\(self.departmentId)&classid=\(Common.shared.classId)&sectionid=\(Common.shared.sectionId)"
        showProgressBar(state:self,activityIndicator: self.activityIndicator)
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
                            for (index,subJson):(String, JSON) in json {
                                self.list.append(SimpleObject(id: subJson["SubjectId"].stringValue, name: subJson["SubjectName"].stringValue))
                            }
                        }else{
                            showToast(state: self, message: "Exception Occurred!")
                        }
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblSubject.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
}

extension NewAssignmentVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectViewCell")
        cell?.textLabel?.text = list[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "addNewAssignmentVC") as! AddNewAssignmentVC
        VC.subjectName = list[indexPath.row].name
        Common.shared.subjectId = list[indexPath.row].id
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}
