//
//  PaymentVC.swift
//  MMIHS
//
//  Created by Frost on 4/16/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PaymentVC: UIViewController {

    @IBOutlet weak var tblPayment: UITableView!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [Payment]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tblPayment.delegate = self
        tblPayment.dataSource = self
        tblPayment.tableFooterView = UIView()
        tblPayment.rowHeight = 70
        
        fnGetPayments(url: appUrl + "GetPaymentHistoryDetail?userid=\(Common.shared.userId)&studentid=\(Common.shared.studentId)&academicsessionid=0")
        
    }
    
    func fnGetPayments( url:String){
        showProgressBar(state: self, activityIndicator: self.activityIndicator)
        self.list.removeAll()
        Alamofire.request(url, method: .get)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let JArray = JSON(json["paymentRecord"].array)
                        if(json["ExceptionType"].stringValue == "" && json["Message"].stringValue == ""){
                            for (index,subJson):(String, JSON) in JArray {
                                var jsonArr = subJson
                                var jsonObj = jsonArr[0]
                                var sList = [Payment]()
                                for (index,JA):(String,JSON) in jsonArr{
                                    sList.append(Payment(recNo: JA["ReceiptNO"].stringValue, fReceiptNo: JA["F_ReceiptNo"].stringValue, fYear: JA["F_Year"].stringValue, accHeadId: JA["accHeadId"].stringValue, accName: JA["ACCOUNTNAME"].stringValue, recAmount: JA["receivedAmount"].stringValue, extraDiscount: JA["extraDiscount"].stringValue, recTax: JA["ReceivedTax"].stringValue, paymentDate: JA["paymentDate"].stringValue, paymentType: JA["payment_Type"].stringValue, refundDate: JA["RefundDate"].stringValue, list: []))
                                }
                                self.list.append(Payment(recNo: jsonObj["ReceiptNO"].stringValue, fReceiptNo: jsonObj["F_ReceiptNo"].stringValue, fYear: jsonObj["F_Year"].stringValue, accHeadId: jsonObj["accHeadId"].stringValue, accName: jsonObj["ACCOUNTNAME"].stringValue, recAmount: jsonObj["receivedAmount"].stringValue, extraDiscount: jsonObj["extraDiscount"].stringValue, recTax: jsonObj["ReceivedTax"].stringValue, paymentDate: jsonObj["paymentDate"].stringValue, paymentType: jsonObj["payment_Type"].stringValue, refundDate: jsonObj["RefundDate"].stringValue, list:sList))
                            }
                            
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblPayment.reloadData()
                        }else{
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblPayment.reloadData()
                        }
                    }
                case .failure(let error):
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    showToast(state: self, message: "Network failure")
                }
        }
    }
    
}


extension PaymentVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
            self.tblPayment.setEmptyMessage("")
        } else {
            self.tblPayment.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "paymentViewCell", for: indexPath) as? PaymentViewCell else{
            return UITableViewCell()
        }
        let obj:Payment = list[indexPath.row]
        cell.txtDate.text = obj.paymentDate
        cell.txtMonth.text = obj.paymentDate
        if(obj.paymentDate.count > 2){
            let monthNo = obj.paymentDate.split(separator: "-")
            var month = ""
            if(monthNo.count > 1){
                switch(monthNo[1]){
                case "01":
                    month = "Baishakh"
                    break
                case "02":
                    month = "Jestha"
                    break
                case "03":
                    month = "Ashadh"
                    break
                case "04":
                    month = "Shrawan"
                    break
                case "05":
                    month = "Bhadra"
                    break
                case "06":
                    month = "Ashoj"
                    break
                case "07":
                    month = "Kartik"
                    break
                case "08":
                    month = "Mangsir"
                    break
                case "09":
                    month = "Poush"
                    break
                case "10":
                    month = "Magh"
                    break
                case "11":
                    month = "Falgun"
                    break
                case "12":
                    month = "Chaitra"
                    break
                default:
                    break
                }
            }
            cell.txtMonth.text = String(month)
        }
        cell.txtFeeType.text = obj.paymentType
        cell.txtFiscalYear.text = obj.fYear
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "feeDetailVC") as! FeeDetailVC
        VC.payment = list[indexPath.row]
        VC.headerTitle = "PaymentDetail"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    
}
