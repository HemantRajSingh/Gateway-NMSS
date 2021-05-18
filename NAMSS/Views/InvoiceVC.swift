//
//  InvoiceVC.swift
//  MMIHS
//
//  Created by Frost on 4/16/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InvoiceVC: UIViewController {
    
    var list = [Invoice]()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var tblInvoice: UITableView!
    @IBOutlet weak var txtTotalInvoice: UILabel!
    @IBOutlet weak var txtTotalPayment: UILabel!
    @IBOutlet weak var txtTotalDues: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblInvoice.delegate = self
        tblInvoice.dataSource = self
        tblInvoice.tableFooterView = UIView()
        tblInvoice.rowHeight = 80
        fnGetInvoices(url: appUrl + "GetFeeHistoryDetail?userid=\(Common.shared.userId)&studentid=\(Common.shared.studentId)&academicsessionid=0")

    }
    
    func fnGetInvoices( url:String){
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
                        if(json["ExceptionType"].stringValue == "" && json["Message"].stringValue == ""){
                            let feeDetail = JSON(json["feeDetail"].dictionary)
                            self.txtTotalInvoice.text = String(feeDetail["thisMonthBill"].stringValue)
                            self.txtTotalPayment.text = String(feeDetail["previousDues"].stringValue)
                            self.txtTotalDues.text = String(feeDetail["totalDues"].stringValue)
//                            let JA = JSON(json["invoiceRecord"].array)
//                            let paymentArray = JSON(json["paymentRecord"].array)
//                            var masterNo = "",invoiceDate = "",invoiceDateEn = "",noOfBilledMonths = "",orgId = "",detailInvoiceNo = "",invAmount = "",discountedAmount = "",taxAmount = "",accHeadId = "",accName = "",monthId = "",monthName = ""
//                            var subList:[Invoice] = [Invoice]()
//                            if(json["ExceptionType"].stringValue == "" && json["Message"].stringValue == ""){
//                                var totalInvoice = 0.00,totalPayment = 0.00
//                                for (index,subJson):(String, JSON) in JA {
//                                    var sjson = subJson[0]
//                                    masterNo = sjson["masterNo"].stringValue
//                                    invoiceDate = sjson["invoiceDate"].stringValue
//                                    for (index,jsonObj):(String,JSON) in subJson{
//                                        masterNo = jsonObj["masterNo"].stringValue
//                                        invoiceDate = jsonObj["invoiceDate"].stringValue
//                                        invoiceDateEn = jsonObj["invoiceDate_EN"].stringValue
//                                        noOfBilledMonths = jsonObj["NoOfBilledMonths"].stringValue
//                                        orgId = jsonObj["OrganizationID"].stringValue
//                                        detailInvoiceNo = jsonObj["detailInvoiceNo"].stringValue
//                                        invAmount = jsonObj["invAmount"].stringValue
//                                        totalInvoice += Double(invAmount) ?? 0.0
//                                        discountedAmount = jsonObj["DiscountedAmount"].stringValue
//                                        taxAmount = jsonObj["TaxAmount"].stringValue
//                                        accHeadId = jsonObj["accHeadId"].stringValue
//                                        accName = jsonObj["ACCOUNTNAME"].stringValue
//                                        monthId = jsonObj["MonthId"].stringValue
//                                        monthName = jsonObj["MONTHNAME"].stringValue
//                                        subList.append(Invoice(masterNo: masterNo, invoiceDate: invoiceDate, invoiceDateEn: invoiceDateEn, noOfBilledMonths: noOfBilledMonths, orgId: orgId, detailInvoiceNo: detailInvoiceNo, invAmount: invAmount, discountedAmount: discountedAmount, taxAmount: taxAmount, accHeadId: accHeadId, accName: accName, monthId: monthId, monthName: monthName, list:[]))
//                                    }
//                                    self.list.append(Invoice(masterNo: masterNo, invoiceDate: invoiceDate, invoiceDateEn: invoiceDateEn, noOfBilledMonths: noOfBilledMonths, orgId: orgId, detailInvoiceNo: detailInvoiceNo, invAmount: invAmount, discountedAmount: discountedAmount, taxAmount: taxAmount, accHeadId: accHeadId, accName: accName, monthId: monthId, monthName: monthName, list:subList))
//                                }
//
//                                for (index,subJson):(String, JSON) in paymentArray {
//                                    var jsonArr = subJson
//                                    var jsonObj = jsonArr[0]
//                                    var sList = [Payment]()
//                                    for (index,JA):(String,JSON) in jsonArr{
//                                        var receivedAmount = JA["receivedAmount"].stringValue
//                                        totalPayment += Double(receivedAmount) ?? 0.00
//                                    }
//                                }
//                                self.txtTotalInvoice.text = String(totalInvoice)
//                                self.txtTotalPayment.text = String(totalPayment)
//                                self.txtTotalDues.text = String(totalInvoice - totalPayment)
//                            }else{
//                                showToast(state: self, message: "Exception Occurred!")
//                            }
                            
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblInvoice.reloadData()
                        }else{
                            hideProgressBar(activityIndicator: self.activityIndicator)
                            self.tblInvoice.reloadData()
                        }
                    }
                case .failure(let error):
                    hideProgressBar(activityIndicator: self.activityIndicator)
                    showToast(state: self, message: "Network failure")
                }
        }
    }
    
}

extension InvoiceVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(list.count == 0){
//            self.tblInvoice.setEmptyMessage("")
        } else {
            self.tblInvoice.restore()
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "invoiceViewCell", for: indexPath) as? InvoiceViewCell else{
            return UITableViewCell()
        }
        let obj:Invoice = list[indexPath.row]
        cell.txtDate.text = obj.invoiceDate
        cell.txtMonth.text = obj.monthName
        cell.txtInvoiceNo.text = "Invoice No: " + obj.masterNo
        cell.txtBilledMonth.text = "No. of Billed Months : " + obj.noOfBilledMonths
        let invoices:[Invoice] = obj.list
        var total:Double = Double()
        for i in invoices{
            total += Double(i.invAmount) ?? 0.0
        }
        cell.txtTotal.text = String(total)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC =  storyboard.instantiateViewController(withIdentifier: "feeDetailVC") as! FeeDetailVC
        VC.invoice = list[indexPath.row]
        VC.headerTitle = "InvoiceDetail"
        self.navigationController?.pushViewController(VC, animated: true)
    }
}
