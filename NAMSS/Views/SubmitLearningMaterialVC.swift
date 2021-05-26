//
//  SubmitLearningMaterialVC.swift
//  NAMSS
//
//  Created by ITH on 26/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit
import SwiftyJSON
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

class SubmitLearningMaterialVC: UIViewController {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    private var imagePicker = UIImagePickerController()
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
    @IBOutlet weak var labelDocumentLink: UILabel!
    var base64String = ""
    
    var periodId = "",subjectId = "",sectionId = "",classId = "",facultyId="",departmentId = "",materialId = "",materialFileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let doneButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.submitLink(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.txtRemarks.layer.borderColor = UIColor.lightGray.cgColor;
        self.txtRemarks.layer.borderWidth = 1.0;
        self.txtRemarks.layer.cornerRadius = 8;
        self.txtFileName.text = ""
        
        self.loadFaculty()
        self.loadMaterialTypes()
        self.imagePicker.delegate = self
       
    }
    
    @IBAction func selectFile(_ sender: Any) {
        
        var alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        if(self.materialId.lowercased() == "pdf"){
            alert = UIAlertController(title: "Select File", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Open Files", style: .default, handler: { _ in
                self.selectFiles()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallary()
            }))
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender as! UIView
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectFiles() {
        let types: [String] = [kUTTypePDF as String, kUTTypeText as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        
//        if #available(iOS 14, *) {
//            var config = PHPickerConfiguration()
//            config.selectionLimit = 1
//            config.filter = PHPickerFilter.images
//            let pickerViewController = PHPickerViewController(configuration: config)
//            pickerViewController.delegate = self
//            self.present(pickerViewController, animated: true, completion: nil)
//        } else {
//            // Fallback on earlier versions
//        }

        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
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
                    if(res.id.lowercased() == "audiolink" || res.id.lowercased() == "videolink"){
                        self.viewFileSelectHeight.constant = 0
                        self.viewFileSelect.isHidden = true
                        self.labelDocumentLink.isHidden = false
                        self.txtDocumentLink.isHidden = false
                    } else{
                        self.labelDocumentLink.isHidden = true
                        self.txtDocumentLink.isHidden = true
                        self.viewFileSelect.isHidden = false
                        self.viewFileSelectHeight.constant = 50
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
        if(self.materialId.lowercased() == "audiolink" || self.materialId.lowercased() == "videolink") {
            base64String = txtDocumentLink.text ?? ""
        } else {
            if(self.materialId.lowercased() == "image"){
                base64String = "data:application/image;base64," + base64String
            } else if(self.materialId.lowercased() == "pdf") {
                base64String = "data:application/pdf;base64," + base64String
            }
        }
        json["DocumentUrl"] = base64String
        
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

extension SubmitLearningMaterialVC : UITextFieldDelegate, UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageData:Data = pickedImage.pngData()!
            base64String = imageData.base64EncodedString()
        }
        
        self.txtFileName.text = "Image selected"
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SubmitLearningMaterialVC : UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        
        do {
            let fileData:Data = try Data.init(contentsOf: myURL)
            base64String = fileData.base64EncodedString()
            self.txtFileName.text = "\(myURL.lastPathComponent) selected"
        } catch {
            print("The file could not be loaded")
            self.txtFileName.text = "Failed to load selected File!"
            showToast(state: self, message: "Failed to load selected File!")
        }
    }
    
}

//@available(iOS 14, *)
//extension SubmitLearningMaterialVC : PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        for result in results {
//            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
//                if let image = object as? UIImage {
//                    DispatchQueue.main.async {
//                        // Use UIImage
//                        self.txtFileName.text = result.assetIdentifier?.description
//                        let imageData:Data = image.pngData()!
//                        self.base64String = imageData.base64EncodedString()
//                    }
//                }
//            })
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
