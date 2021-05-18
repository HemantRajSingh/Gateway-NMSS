//
//  ViewController.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 2/24/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SafariServices

class ViewController: UIViewController, UITextFieldDelegate {
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var switchRememberMe: UISwitch!
    private var menus = [Menu]()
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    var username:String = ""
    var password:String = ""
    @IBOutlet weak var txtSchoolName: UILabel!
    @IBOutlet weak var txtSchoolAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSchoolName.text = schoolName
        txtSchoolAddress.text = schoolAddress
        self.txtUsername.delegate = self
        self.txtPassword.delegate = self
        txtUsername.text = UserDefaults.standard.string(forKey:"username") ?? ""
        txtPassword.text = UserDefaults.standard.string(forKey:"password") ?? ""
        if(UserDefaults.standard.bool(forKey: "rememberMe")){
            switchRememberMe.isOn = true
            let u = UserDefaults.standard.string(forKey: "username") ?? ""
            let p = UserDefaults.standard.string(forKey: "password") ?? ""
            if(u != "" && p != ""){
                self.fnLoginV2(url: appUrl + "GetUserAuthenticated?username="+u+"&password="+p+"&dtoken="+firebaseToken)
            }
        }
        
        menus.append(Menu(menuId:1,view:"noticeVC", menuImage: #imageLiteral(resourceName: "ic_aboutus"), menuTitle: "NOTICE", menuDesc: ""))
        menus.append(Menu(menuId:1,view:"calendarVC", menuImage: #imageLiteral(resourceName: "ic_main_event"), menuTitle: "EVENTS", menuDesc: ""))
        menus.append(Menu(menuId:1,view:"contactVC", menuImage: #imageLiteral(resourceName: "ic_contactus"), menuTitle: "CONTACT", menuDesc: ""))
        menus.append(Menu(menuId:1,view:"aboutVC", menuImage: #imageLiteral(resourceName: "ic_aboutus"), menuTitle: "ABOUT US", menuDesc: ""))
    }
    
    @IBAction func sigin(_ sender: UIButton) {
        username = txtUsername.text ?? ""
        password = txtPassword.text ?? ""
        
        if(username.isEmpty || password.isEmpty){
            displayAlertMessage(state:self, msg:"Username or password is empty!")
        }else{
            
            self.fnLoginV2(url: appUrl + "GetUserAuthenticated?username="+username+"&password="+password+"&dtoken="+firebaseToken)
        }
        
    }
    
    func fnLoginV2( url:String){
        self.view.endEditing(true)
        showProgressBarIgnoringUserEvents(state: self, activityIndicator: self.activityIndicator)
        Alamofire.request(url, method: .get)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let loginResult = json["loginResult"].bool {
                            if(loginResult == true){
                                let userId = String(json["userId"].int ?? 0)
                                Common.shared.userId = userId
                                let userRole = json["userRole"].string
                                Common.shared.userRole = userRole ?? ""
                                switch userRole{
                                case "AppAdmin","AppTeacher":
                                    if let jo = json["teacher"].dictionary{
                                        Common.shared.userDetail = jo
                                        Common.shared.teacherId = String(jo["StaffID"]?.int ?? 0)
                                        Common.shared.staffId = String(jo["StaffID"]?.int ?? 0)
                                        Common.shared.memberTypeId = String(jo["MemberTypeID"]?.int ?? 0)
                                    }
                                    break
                                case "AppStudent":
                                    if let jo = json["student"].dictionary{
                                        Common.shared.userDetail = jo
                                        Common.shared.studentId = String(jo["STUDENTID"]?.int ?? 0)
                                        Common.shared.parentId = String(jo["AppParentID"]?.int ?? 0)
                                    }
                                    break
                                case "AppParent":
                                    if let jo = json["parent"].dictionary{
                                        Common.shared.userDetail = jo
                                        Common.shared.studentId = String(jo["STUDENTID"]?.int ?? 0)
                                    }
                                    break
                                case .none:
                                    break
                                case .some(_):
                                    break
                                }
//                                let parent = json["parent"].array
//                                let parentData = NSKeyedArchiver.archivedData(withRootObject: parent as Any)
//                                let guardian = json["guardian"].array
//                                let guardianData = NSKeyedArchiver.archivedData(withRootObject: guardian as Any)
//                                let student = String(json["student"].dictionary ?? [:])
//                                let teacher = json["teacher"].array
//                                let teacherData = NSKeyedArchiver.archivedData(withRootObject: teacher as Any)
                                var userimage = json["userimage"].string
                                userimage = userimage?.replacingOccurrences(of: " ", with: "%20")
                                UserDefaults.standard.set(self.username,forKey:"username")
                                Common.shared.username = self.username
                                UserDefaults.standard.set(self.password,forKey:"password")
                                UserDefaults.standard.set(userId,forKey:"userId")
                                UserDefaults.standard.set(userRole,forKey:"userRole")
                                UserDefaults.standard.set(self.switchRememberMe.isOn,forKey: "rememberMe")
//                                UserDefaults.standard.set(parentData,forKey:"parent")
//                                UserDefaults.standard.set(guardianData,forKey:"guardian")
//                                UserDefaults.standard.set(student,forKey:"student")
//                                UserDefaults.standard.set(teacherData,forKey:"teacher")
                                UserDefaults.standard.set(userimage,forKey:"userimage")
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let dashboardVC =  storyboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
                                hideProgressBar(activityIndicator: self.activityIndicator)
                                self.navigationController?.pushViewController(dashboardVC, animated: true)
                            }else{
                                showToast(state: self, message: "Username or password Wrong. Please try again!")
                                hideProgressBar(activityIndicator: self.activityIndicator)
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                    showToast(state: self, message: "Network Failure. Please try again!")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
        
    }
    
    func fnSetUserDefaults(){
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

