//
//  MessageViewVC.swift
//  MMIHS
//
//  Created by Frost on 5/26/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MessageViewVC: UIViewController {

    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [MessageView]()
    @IBOutlet weak var tblMessage: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMessage.tableFooterView = UIView()
        self.fnGetMessages()
    }
    
    func fnGetMessages(){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        self.list.removeAll()
        let url = appUrl + "GetStudentMessageFromTeacher?userid=\(Common.shared.userId)&studentid=\(Common.shared.studentId)&readall=false"
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
                                self.list.append(MessageView(teacherName: subJson["teacherName"].stringValue, subject: subJson["subject"].stringValue, message: subJson["message"].stringValue, date: subJson["messageDate"].stringValue))
                            }
                        }else{
                            showToast(state: self, message: "Error Occured. Please Try Again!")
                        }
                        
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblMessage.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    showToast(state: self, message: "Network error")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
    }
    
}

extension MessageViewVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            self.tblMessage.setEmptyMessage("")
        } else {
            self.tblMessage.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageViewCell") as? MessageViewCell else {
            return UITableViewCell()
        }
        cell.txtname.text = list[indexPath.row].teacherName
        cell.txtMessage.text = list[indexPath.row].message
        cell.txtDate.text = list[indexPath.row].date
        cell.imgImage.layer.cornerRadius = cell.imgImage.frame.size.width / 2
        cell.imgImage.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Message", message: list[indexPath.row].message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
