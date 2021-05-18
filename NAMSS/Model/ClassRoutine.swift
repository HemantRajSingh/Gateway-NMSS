//
//  ClassRoutine.swift
//  MMIHS
//
//  Created by Frost on 1/1/18.
//  Copyright © 2018 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class ClassRoutine: NSObject {
    
    var classId,className,periodId,periodName,startTime,endTime,staffId,staffName,date : String
    
    init(classId:String,className:String,periodId:String,periodName:String,startTime:String,endTime:String,staffId:String,staffName:String,date:String){
        self.classId = classId
        self.className = className
        self.periodId = periodId
        self.periodName = periodName
        self.startTime = startTime
        self.endTime = endTime
        self.staffId = staffId
        self.staffName = staffName
        self.date = date
    }
    
}
