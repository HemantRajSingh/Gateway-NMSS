//
//  Staff.swift
//  MMIHS
//
//  Created by Frost on 3/30/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Staff: NSObject {
    
    var staffId,staffCode,staffName,staffRank,attendanceId,designationId,designationName,departmentId,department,mobile,staffShiftId,shiftName,startTime,endTime:String
    
    var deviceLog:[String]
    init(staffId:String,staffCode:String,staffName:String,staffRank:String,attendanceId:String,designationId:String,designationName:String,departmentId:String,department:String,mobile:String,staffShiftId:String,shiftName:String,startTime:String,endTime:String,deviceLog:[String]){
        self.staffId = staffId
        self.staffCode = staffCode
        self.staffName = staffName
        self.staffRank = staffRank
        self.attendanceId = attendanceId
        self.designationId = designationId
        self.designationName = designationName
        self.departmentId = departmentId
        self.department = department
        self.mobile = mobile
        self.staffShiftId = staffShiftId
        self.shiftName = shiftName
        self.startTime = startTime
        self.endTime = endTime
        self.deviceLog = deviceLog
    }

}
