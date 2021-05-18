//
//  AboutVC.swift
//  MMIHS
//
//  Created by Frost on 4/13/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AboutVC: UIViewController {

    var list = [Contact]()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tblContact: UITableView!
    @IBOutlet weak var txtPhone: UILabel!
    @IBOutlet weak var txtSchoolName: UILabel!
    @IBOutlet weak var txtSchoolAddress: UILabel!
    
    @IBOutlet weak var txtWebsite: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblContact.delegate = self
        self.tblContact.dataSource = self
        self.tblContact.tableFooterView = UIView()
        txtSchoolName.text = schoolName
        txtSchoolAddress.text = schoolAddress
        
        showProgressBar(state: self, activityIndicator: activityIndicator)
        fnGetOrganizationInfo(url: appUrl + "GetOrganizationInformation")
    }
    
    func fnGetOrganizationInfo(url:String){
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
                            self.txtPhone.text = json["InstitutePhoneNumber"].stringValue
                            self.txtWebsite.text = json["InstituteWebsite"].stringValue
                            let arr = json["StaffContactList"]
                            for (index,subJson):(String, JSON) in arr {
                                self.list.append(Contact(name: subJson["StaffName"].stringValue, dep: subJson["Department"].stringValue, des: subJson["DesignationName"].stringValue, mobile: subJson["MobileNo"].stringValue))
                            }
                        }else{
                            showToast(state: self, message: "Exception Occurred!")
                        }
                        
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblContact.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    showToast(state: self, message: "Network error")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
    }

}

extension AboutVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "staffViewCell") as? StaffViewCell else {
            return UITableViewCell()
        }
        cell.txtName.text = list[indexPath.row].name
        cell.txtDepartment.text = list[indexPath.row].dep
        cell.txtDesignation.text = list[indexPath.row].des
        cell.txtMobile.text = list[indexPath.row].mobile
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
