//
//  Payment.swift
//  MMIHS
//
//  Created by Frost on 4/16/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Payment: NSObject {
    
    var recNo="",fReceiptNo="",fYear="",accHeadId="",accName="",recAmount="",extraDiscount="",recTax="",paymentDate="",paymentType="",refundDate=""
    var list:[Payment] = []
    init(recNo:String,fReceiptNo:String,fYear:String,accHeadId:String,accName:String,recAmount:String,extraDiscount:String,recTax:String,paymentDate:String,paymentType:String,refundDate:String,list:[Payment]){
        self.recNo = recNo
        self.fReceiptNo = fReceiptNo
        self.fYear = fYear
        self.accHeadId = accHeadId
        self.accName = accName
        self.recAmount = recAmount
        self.extraDiscount = extraDiscount
        self.recTax = recTax
        self.paymentDate = paymentDate
        self.paymentType = paymentType
        self.refundDate = refundDate
        self.list = list
    }
    
    override init(){
        
    }

}
