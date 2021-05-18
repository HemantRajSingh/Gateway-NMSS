//
//  FeeDetailVC.swift
//  MMIHS
//
//  Created by Frost on 4/21/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class FeeDetailVC: UIViewController {

    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var headerTitle = ""
    var invoice = Invoice.init()
    var payment = Payment.init()
    @IBOutlet weak var txtId: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var tblTable: UITableView!
    @IBOutlet weak var txtTotal: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblTable.delegate = self
        self.tblTable.dataSource = self
        self.tblTable.tableFooterView = UIView()
        self.tblTable.rowHeight = 25
        
        if(headerTitle.lowercased() == "invoicedetail"){
            txtId.text = "Invoice No: " + invoice.masterNo
            txtName.text = headerTitle
            var total = Decimal()
            for i in invoice.list{
                total += Decimal(string:i.invAmount) ?? 0.0
            }
            txtDate.text = "Date: \(invoice.invoiceDate)"
            txtTotal.text = "Total : \(total)"
        } else {
            txtId.text = "Receipt No: " + payment.recNo
            txtName.text = headerTitle
            var total = Decimal()
            for i in payment.list{
                total += Decimal(string:i.recAmount) ?? 0.0
            }
            txtDate.text = "Date: \(payment.paymentDate)"
            txtTotal.text = "Total : \(total)"
        }
    }

}

extension FeeDetailVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(headerTitle.lowercased() == "invoicedetail"){
            return invoice.list.count
        }else{
            return payment.list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feeViewCell") as? FeeViewCell else {
            return UITableViewCell()
        }
        if(headerTitle.lowercased() == "invoicedetail"){
            cell.txtName.text = invoice.list[indexPath.row].accName
            cell.txtAmount.text = invoice.list[indexPath.row].invAmount
        }else{
            cell.txtName.text = payment.list[indexPath.row].accName
            cell.txtAmount.text = payment.list[indexPath.row].recAmount
        }
        return cell
    }
    
}

