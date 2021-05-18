//
//  ResultVC.swift
//  MMIHS
//
//  Created by Frost on 4/13/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResultVC: UIViewController {

    @IBOutlet weak var tblExam: UITableView!
    var list = [SimpleObject]()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblExam.delegate = self
        tblExam.dataSource = self
        tblExam.rowHeight = 40
        tblExam.tableFooterView = UIView()
        
//        list.append(SimpleObject(id: "1", name: "exam1"))
//        list.append(SimpleObject(id: "2", name: "exam2"))
//        list.append(SimpleObject(id: "3", name: "exam3"))
        
        showProgressBar(state: self, activityIndicator: activityIndicator)
        fnGetExamList(url: appUrl + "GetAllExamlist?userid=\(Common.shared.userId)")

    }
    
    func fnGetExamList(url:String){
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
                                self.list.append(SimpleObject(id: subJson["ExamId"].stringValue, name: subJson["ExamName"].stringValue))
                            }
                        }else{
                            showToast(state: self, message: "Exception occurred!")
                        }
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblExam.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    showToast(state: self, message: "Network error")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
    }

}

extension ResultVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "examViewCell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].name
        cell.textLabel?.font = cell.textLabel?.font.withSize(15)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Common.shared.examId = list[indexPath.row].id
//        openView(state: self, viewName: "resultContentVC")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "resultContentVC") as!  ResultContentVC
        VC.examTitle = list[indexPath.row].name
        VC.examId = list[indexPath.row].id
        VC.type = "result"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
}
