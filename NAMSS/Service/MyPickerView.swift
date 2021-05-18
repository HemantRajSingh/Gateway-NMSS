//
//  MyPickerView.swift
//  MMIHS
//
//  Created by Frost on 3/29/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import Foundation
import UIKit

class MyPickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerData : [SimpleObject]!
    var pickerTextField : UITextField!
    var type:String = ""
    var completionHandler : ((SimpleObject)->Void)?
    
    init(pickerData: [SimpleObject], dropdownField: UITextField,type:String, completionHandler: @escaping ((SimpleObject) -> Void)) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        
        self.pickerData = pickerData
        self.pickerTextField = dropdownField
        self.pickerTextField.isEnabled = false
        self.type = type
        
        self.delegate = self
        self.dataSource = self
        
        DispatchQueue.main.async {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData[0].name
                self.pickerTextField.isEnabled = true
//                switch(type){
//                case "faculty":
//                    Common.shared.facultyId = pickerData[0].id
//                    break
//                case "department":
//                    Common.shared.departmentId = pickerData[0].id
//                    break
//                case "class":
//                    Common.shared.classId = pickerData[0].id
//                    break
//                case "section":
//                    Common.shared.sectionId = pickerData[0].id
//                    break
//                default:
//                    break
//                }
                self.completionHandler = completionHandler
                if(self.completionHandler != nil){
                    self.completionHandler!(pickerData[0])
                }
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData![row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row].name
        
//        switch(type){
//        case "faculty":
//            Common.shared.facultyId = pickerData[row].id
//            break
//        case "department":
//            Common.shared.departmentId = pickerData[row].id
//            break
//        case "class":
//            Common.shared.classId = pickerData[row].id
//            break
//        case "section":
//            Common.shared.sectionId = pickerData[row].id
//            break
//        default:
//            break
//        }
        
        if(self.completionHandler != nil){
            self.completionHandler!(pickerData[row])
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}
