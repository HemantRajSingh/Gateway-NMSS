//
//  ProfileVC.swift
//  MMIHS
//
//  Created by Frost on 4/19/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileVC: UIViewController {
    
    var pList = [SimpleObject]()
    var aList = [SimpleObject]()
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let userRole = Common.shared.userRole

    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ptableHeight: NSLayoutConstraint!
    @IBOutlet weak var ptable: UITableView!
    @IBOutlet weak var atable: UITableView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose,target: self, action: #selector(self.changePassword(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        ptable.delegate = self
        ptable.dataSource = self
        ptable.tableFooterView = UIView()
        atable.delegate = self
        atable.dataSource = self
        ptable.rowHeight = 30
        atable.rowHeight = 30
        atable.tableFooterView = UIView()
        
        imgProfile.setRounded()
        let encoded64 = UserDefaults.standard.string(forKey: "userimage") ?? ""
        if(encoded64 != ""){
            var imageUrl = encoded64.replacingOccurrences(of: "~", with: baseUrl)
            imgProfile.kf.setImage(with: URL(string: imageUrl))
        }
        
        for(key,value) in Common.shared.userDetail ?? [:]{
            if(key == "StaffName"){
                self.txtName.text = value.stringValue
            }
            self.pList.append(SimpleObject(id: key, name: value.stringValue))
        }
        ptable.reloadData()
        if(userRole == "AppStudent" || userRole == "AppParent"){
            fnGetPersonalDesc(url: appUrl + "GetStudentInfo?id=" + Common.shared.studentId)
        }
    }
    
    @objc func changePassword(sender:UIBarButtonItem){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "changePasswordVC")
        VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.addChild(VC)
//        VC!.view.frame = self.view.frame
        self.view.addSubview(VC.view)
//        VC?.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width:
            self.view.frame.size.width, height:self.view.frame.size.height + 300)
    }
    
    func fnGetPersonalDesc( url:String){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        self.pList.removeAll()
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
                            for (key,value) in json {
                                if(key == "StudentName"){
                                    self.txtName.text = value.stringValue
                                }
                                if(self.userRole == "AppStudent"){
                                    self.pList.append(SimpleObject(id: key, name: value.stringValue))
                                }else{
                                    self.aList.append(SimpleObject(id: key, name: value.stringValue))
                                }
                            }
                            hideProgressBar(activityIndicator: self.activityIndicator)
//                            self.ptableHeight.constant = CGFloat(self.pList.count * 50)
//                            self.ptable.frame.size.height = CGFloat(self.pList.count) * 45
//                            self.atable.frame.size.height = CGFloat(self.aList.count) * 45
                            self.ptable.reloadData()
                            self.atable.reloadData()
                        }else{
                            showToast(state: self, message: "Server Error. Please Try Again")
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.ptable.reloadData()
                            self.atable.reloadData()
                        }
                    }
                case .failure(let error):
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    showToast(state: self, message: "Network failure")
                }
        }
    }

}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.ptable){
            return pList.count
        }else{
            return aList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.ptable){
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileViewCell", for: indexPath) as? ProfileViewCell
            let obj:SimpleObject = pList[indexPath.row]
            cell?.txtName.text = obj.id
            cell?.txtDescription.text = obj.name
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell!
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "profile2ViewCell", for: indexPath) as? Profile2ViewCell
            let obj:SimpleObject = aList[indexPath.row]
            cell?.txtName.text = obj.id
            cell?.txtDescription.text = obj.name
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell!
        }
    }
    
}
