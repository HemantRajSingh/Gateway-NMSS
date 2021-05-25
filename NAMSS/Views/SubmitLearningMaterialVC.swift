//
//  SubmitLearningMaterialVC.swift
//  NAMSS
//
//  Created by ITH on 26/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubmitLearningMaterialVC: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var dropdownFaculty: UITextField!
    @IBOutlet weak var dropdownProgram: UITextField!
    @IBOutlet weak var dropdownClass: UITextField!
    @IBOutlet weak var dropdownSection: UITextField!
    @IBOutlet weak var dropdownSubject: UITextField!
    @IBOutlet weak var dropdownMaterial: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtRemarks: UITextView!
    @IBOutlet weak var btnSelectFile: UIButton!
    @IBOutlet weak var viewFileSelectHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFileSelect: UIView!
    @IBOutlet weak var txtFileName: UILabel!
    @IBOutlet weak var txtDocumentLink: UITextField!
    
    var periodId = "",subjectId = "",sectionId = "",classId = "",facultyId="",departmentId = "",materialId = "",materialFileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let doneButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.submitLink(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.txtRemarks.layer.borderColor = UIColor.lightGray.cgColor;
        self.txtRemarks.layer.borderWidth = 1.0;
        self.txtRemarks.layer.cornerRadius = 8;
        
        self.loadFaculty()
        self.loadMaterialTypes()
       
    }
    
    
    @IBAction func selectFile(_ sender: Any) {
    }
    
    func loadMaterialTypes(){
        var sectionList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetLearningMaterialTypes", completionHandler: {(res,json)->Void in
            if(res == true){
                for (_,subJson):(String, JSON) in json {
                    sectionList.append(SimpleObject(id: subJson["Id"].stringValue, name: subJson["Name"].stringValue))
                }
                self.dropdownMaterial.loadDropdownData(data: sectionList, type:"section", completionHandler: {(res) in
                    self.materialId = res.id
                    if(res.id.lowercased() == "audiolink" || res.name.lowercased() == "videolink"){
                        self.viewFileSelectHeight.constant = 0
                        self.viewFileSelect.isHidden = true
                    } else{
                        
                    }
                    hideProgressBar(activityIndicator: self.activityIndicator)
                })
            }else{
                showToast(state: self, message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    @objc func submitLink(sender: UIBarButtonItem){
        
        var json = [String:String]()
        json["FacultyId"] = self.facultyId
        json["ProgramId"] = self.departmentId
        json["ClassId"] = self.classId
        json["SubjectId"] = self.subjectId
        json["MaterialType"] = self.dropdownMaterial.text ?? ""
        json["DocumentTitle"] = self.txtTitle.text ?? ""
        json["Remarks"] = self.txtRemarks.text ?? ""
        json["SubmitById"] = Common.shared.teacherId
        json["DocumentUrl"] = materialFileName
        
        fnPostApiWithJson(url: appUrl + "SubmitLearningMaterials", json: JSON(json), completionHandler: {(res,json)->Void in
            if(res){
                showToast(state: self, message: "\(self.txtRemarks.text ?? "") added!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                showToast(state: self, message: "Error Adding \(self.dropdownMaterial.text ?? ""). Please Try again")
            }
        })
    }
    
    func loadFaculty(){
        showProgressBar(state:self,activityIndicator: self.activityIndicator)
        var facultyList = [SimpleObject]()
        fnGetApi(url: appUrl + "GetFaculty", completionHandler: {(res,json)->Void in
            if(res == true){
                self.loadDepartment()
                for (_,subJson):(String, JSON) in json {
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
                for (_,subJson):(String, JSON) in json {
                    dapartmentList.append(SimpleObject(id: subJson["DEPARTMENTID"].stringValue, name: subJson["DEPARTMENTNAME"].stringValue))
                }
                self.dropdownProgram.loadDropdownData(data: dapartmentList, type:"department", completionHandler: {(res) in
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
                for (_,subJson):(String, JSON) in json {
                    classList.append(SimpleObject(id: subJson["CLASSID"].stringValue, name: subJson["CLASSNAME"].stringValue))
                }
                self.dropdownClass.loadDropdownData(data: classList, type:"class", completionHandler: {(res) in
                    self.classId = res.id
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
        fnGetApi(url: appUrl + "GetSectionByClass?classid=\(self.classId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (_,subJson):(String, JSON) in json {
                    sectionList.append(SimpleObject(id: subJson["SECTIONID"].stringValue, name: subJson["SECTIONNAME"].stringValue))
                }
                self.dropdownSection.loadDropdownData(data: sectionList, type:"section", completionHandler: {(res) in
                    self.sectionId = res.id
                    self.loadSubject()
                })
            }else{
                showToast(state: self, message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    func loadSubject(){
        var sectionList = [SimpleObject]()
        sectionList.append(SimpleObject(id: "", name: "Select"))
        fnGetApi(url: appUrl + "GetSubjectList?facultyid=\(self.facultyId)&departmentid=\(self.departmentId)&classid=\(self.classId)&sectionid=\(self.sectionId)", completionHandler: {(res,json)->Void in
            if(res == true){
                for (_,subJson):(String, JSON) in json {
                    sectionList.append(SimpleObject(id: subJson["SubjectId"].stringValue, name: subJson["SubjectName"].stringValue))
                }
                self.dropdownSubject.loadDropdownData(data: sectionList, type:"section", completionHandler: {(res) in
                    self.subjectId = res.id
                    hideProgressBar(activityIndicator: self.activityIndicator)
                })
            }else{
                showToast(state: self, message: "Something error")
                hideProgressBar(activityIndicator: self.activityIndicator)
            }
        })
    }
    
    
}
