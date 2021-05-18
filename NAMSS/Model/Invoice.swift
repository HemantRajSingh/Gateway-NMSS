//
//  Invoice.swift
//  MMIHS
//
//  Created by Frost on 3/30/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Invoice: NSObject {
    
    var masterNo = "",invoiceDate = "",invoiceDateEn="",noOfBilledMonths="",orgId="",detailInvoiceNo="",invAmount="",discountedAmount="",taxAmount="",accHeadId="",accName="",monthId="",monthName=""
    var list:[Invoice] = []
    
    init(masterNo:String,invoiceDate:String,invoiceDateEn:String,noOfBilledMonths:String,orgId:String,detailInvoiceNo:String,invAmount:String,discountedAmount:String,taxAmount:String,accHeadId:String,accName:String,monthId:String,monthName:String,list:[Invoice]){
        self.masterNo = masterNo
        self.invoiceDate = invoiceDate
        self.invoiceDateEn = invoiceDateEn
        self.noOfBilledMonths = noOfBilledMonths
        self.orgId = orgId
        self.detailInvoiceNo = detailInvoiceNo
        self.invAmount = invAmount
        self.discountedAmount = discountedAmount
        self.taxAmount = taxAmount
        self.accHeadId = accHeadId
        self.accName = accName
        self.monthId = monthId
        self.monthName = monthName
        self.list = list
    }
    
    override init(){
        
    }

}
