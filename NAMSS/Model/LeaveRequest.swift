//
//  LeaveRequest.swift
//  MMIHS
//
//  Created by Frost on 4/12/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class LeaveRequest: NSObject {
    
    var leaveName,facultyLeaveDays,staffLeaveDays,leaveRequestId,requestDate,leavedateFrom,leaveDateTo,leaveTotalDays,status,leaveRequestNo:String
    
    init(leaveName:String,facultyLeaveDays:String,staffLeaveDays:String,leaveRequestId:String,requestDate:String,leavedateFrom:String,leaveDateTo:String,leaveTotalDays:String,status:String,leaveRequestNo:String){
        
            self.leaveName = leaveName
            self.facultyLeaveDays = facultyLeaveDays
            self.staffLeaveDays = staffLeaveDays
            self.leaveRequestId = leaveRequestId
            self.requestDate = requestDate
            self.leavedateFrom = leavedateFrom
            self.leaveDateTo = leaveDateTo
            self.leaveTotalDays = leaveTotalDays
            self.status = status
            self.leaveRequestNo = leaveRequestNo
    }
}
