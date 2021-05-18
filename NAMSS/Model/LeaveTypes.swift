//
//  LeaveTypes.swift
//  MMIHS
//
//  Created by Frost on 4/11/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class LeaveTypes: NSObject {
    
    var id,name,status,organizationId,leaveDays,memberTypeId,year,yearName:String
    
    init(id:String,name:String,status:String,organizationId:String,leaveDays:String,memberTypeId:String,year:String,yearName:String){
        self.id = id
        self.name = name
        self.status = status
        self.organizationId = organizationId
        self.leaveDays = leaveDays
        self.memberTypeId = memberTypeId
        self.year = year
        self.yearName = yearName
    }

}
