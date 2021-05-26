//
//  NewNoticeVC.swift
//  MMIHS
//
//  Created by Frost on 4/22/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NewNoticeVC: UIViewController {

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var imageNotice: UIImageView!
    @IBOutlet weak var datePickerFrom: UITextField!
    @IBOutlet weak var datePicketTo: UITextField!
    private var datePickerClass1:UIDatePicker?
    private var datePickerClass2:UIDatePicker?
    private var imagePicker = UIImagePickerController()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var switchNotify: UISwitch!
    @IBOutlet weak var switchSms: UISwitch!
    @IBOutlet weak var switchApp: UISwitch!
    
    let date = Date()
    let dateFormatter = DateFormatter()
    var base64String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.submitLeave(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        txtDesc.layer.borderColor = UIColor.gray.cgColor
        txtDesc.layer.borderWidth = 1
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
        datePicketTo.text = dateFormatter.string(from: Date())
        datePickerClass2?.addTarget(self, action: #selector(toDateChanged(datePickerField:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        if #available(iOS 14, *) {
            datePickerClass1!.preferredDatePickerStyle = .wheels
            datePickerClass1!.sizeToFit()
            datePickerClass2!.preferredDatePickerStyle = .wheels
            datePickerClass2!.sizeToFit()
        }
        
        imagePicker.delegate = self
        
        datePickerFrom.inputView = datePickerClass1
        datePicketTo.inputView = datePickerClass2

    }

    @IBAction func btnImagePicker(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
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
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func submitLeave(sender: UIBarButtonItem){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        //        var jsonArray = [Dictionary<String, String>]()
        var json = [String:String]()
        json["NotifTitle"] = txtTitle.text ?? ""
        json["NotifDescription"] = txtDesc.text ?? ""
        json["NotifDate"] = datePickerFrom.text
        json["NotifEndDate"] = datePicketTo.text
        json["NotifType"] = "02"
        json["NotifStatus"] = "N"
        if(self.switchNotify.isOn){
            json["NotifStatus"] = "Y"
        }
        json["ClassID"] = Common.shared.classId
        json["SectionID"] = Common.shared.sectionId
        json["isForSMS"] = "false"
        if(self.switchSms.isOn){
            json["isForSMS"] = "true"
        }
        json["isForApp"] = "true"
        if(!self.switchApp.isOn){
            json["isForApp"] = "false"
        }
        json["AppNotificationUsers"] = "null"
        if(base64String != ""){
            base64String = "data:image/jpeg;base64,\(base64String)"
        }
        json["ImageUrl"] = base64String
        //        jsonArray.append(json)
        
        fnPostApiWithJson(url: appUrl + "SaveAppNotification", json: JSON(json), completionHandler: {(res,json)->Void in
            if(res){
                hideProgressBar(activityIndicator: self.activityIndicator)
                showToast(state: self, message: "Notice added")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                hideProgressBar(activityIndicator: self.activityIndicator)
                showToast(state: self, message: "Error Adding notice. Please Try again")
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
        datePicketTo.text = dateFormatter.string(from: datePickerField.date)
        view.endEditing(true)
    }
}


extension NewNoticeVC : UITextFieldDelegate, UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageNotice.image = pickedImage
             self.imageNotice.contentMode = .scaleAspectFit
            let imageData:Data = pickedImage.pngData()!
            base64String = imageData.base64EncodedString()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
