//
//  ChangePasswordVC.swift
//  MMIHS
//
//  Created by Frost on 5/4/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChangePasswordVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var txtOld: UITextField!
    @IBOutlet weak var txtNew: UITextField!
    @IBOutlet weak var txtReNew: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func btnDone(_ sender: Any) {
        if(txtOld.text == "" || txtNew.text == "" || txtReNew.text == ""){
            displayAlertMessage(state: self, msg: "Some of the fields are empty!")
        }else{
            if(txtNew.text == txtReNew.text){
                fnPostApi(url: appUrl + "ResetPassword?username=\(Common.shared.username)&currentPassword=\(txtOld.text ?? "")&newPassword=\(txtNew.text ?? "")", completionHandler:{(res,json) -> Void in
                    if(res && json.stringValue.lowercased().contains("changed successfully")){
                        showToast(state: self, message: "Password changed successfully.")
                        self.removeAnimate()
                    }else{
                        displayAlertMessage(state: self, msg: "Server error. Please Try Again!")
                    }
                })
            }else{
                displayAlertMessage(state: self, msg: "Passwords do not match!")
            }
        }
//        dismiss(animated: true, completion: nil)
    }
    
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
//        removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
