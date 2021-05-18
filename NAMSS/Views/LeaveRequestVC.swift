//
//  LeaveRequestVC.swift
//  MMIHS
//
//  Created by Frost on 4/12/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LeaveRequestVC: UIViewController {
    
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var tblLeaveRequests: UITableView!
    private var list = [LeaveRequest]()
    private var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblLeaveRequests.delegate = self
        tblLeaveRequests.dataSource = self
        tblLeaveRequests.rowHeight = 92
        tblLeaveRequests.tableFooterView = UIView()
        btnNew.backgroundColor = .clear
        btnNew.layer.cornerRadius = 5
        
//        list.append(LeaveRequest(leaveName: "leave 1", facultyLeaveDays: "a", staffLeaveDays: "10", leaveRequestId: "12", requestDate: "20", leavedateFrom: "10", leaveDateTo: "18", leaveTotalDays: "45", status: "requested", leaveRequestNo: "111"))
//        list.append(LeaveRequest(leaveName: "leave 2", facultyLeaveDays: "a", staffLeaveDays: "10", leaveRequestId: "12", requestDate: "20", leavedateFrom: "10", leaveDateTo: "18", leaveTotalDays: "45", status: "rejected", leaveRequestNo: "111"))
//        list.append(LeaveRequest(leaveName: "leave 3", facultyLeaveDays: "a", staffLeaveDays: "10", leaveRequestId: "12", requestDate: "20", leavedateFrom: "10", leaveDateTo: "18", leaveTotalDays: "45", status: "accepted", leaveRequestNo: "111"))
        
    fnGetLeaveRequests(url: appUrl + "GetStaffLeaveRecord?staffId=\(Common.shared.staffId)&userid=\(Common.shared.userId)")

    }
    
    @IBAction func btnNew(_ sender: Any) {
        openView(state: self, viewName: "newLeaveRequestVC")
    }
    
    func fnGetLeaveRequests(url:String){
        showProgressBar(state: self, activityIndicator: activityIndicator)
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
                                self.list.append(LeaveRequest(leaveName: subJson["LeaveName"].stringValue, facultyLeaveDays: subJson["FacultyLeaveDays"].stringValue, staffLeaveDays: subJson["StaffLeaveDays"].stringValue, leaveRequestId: subJson["LeaveRequestId"].stringValue, requestDate: subJson["RequestDate"].stringValue, leavedateFrom: subJson["LeaveDateFrom"].stringValue, leaveDateTo: subJson["LeaveDateTo"].stringValue, leaveTotalDays: subJson["LeaveTotalDays"].stringValue, status: subJson["Status"].stringValue, leaveRequestNo: subJson["LeaveRequestNo"].stringValue))
                            }
                        }else{
                            showToast(state: self, message: "Exception Occurred!")
                        }
                        hideProgressBar(activityIndicator: self.activityIndicator)
                        self.tblLeaveRequests.reloadData()
                    }
                case .failure(let error):
                    print(error)
                    showToast(state: self, message: "Network error")
                    hideProgressBar(activityIndicator: self.activityIndicator)
                }
        }
    }
    
}

extension LeaveRequestVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "leaveViewCell", for: indexPath) as? LeaveViewCell else{
            return UITableViewCell()
        }
        let obj:LeaveRequest = list[indexPath.row]
//        cell.textLabel!.text = list[indexPath.row].leaveName
        cell.txtName.text = obj.leaveName
        cell.txtFromTo.text = obj.leavedateFrom + " : " + obj.leaveDateTo
        cell.txtDuration.text = obj.leaveTotalDays
        cell.txtDate.text = obj.leavedateFrom
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd"
        if(obj.leavedateFrom != ""){
            cell.txtDay.text = dateFormatter1.string(from: dateFormatter.date(from: obj.leavedateFrom) ?? Date())
        }
        cell.txtStatus.setTitle(obj.status, for: .normal)
        if(obj.status.lowercased() == "rejected"){
            cell.txtStatus.setTitleColor(UIColor.red, for: .normal)
        }else if(obj.status.lowercased() == "accepted"){
            cell.txtStatus.setTitleColor(UIColor.green, for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        let view = list[row].leaveName
        showToast(state:self,message: list[row].leaveName)
    }
    
}
