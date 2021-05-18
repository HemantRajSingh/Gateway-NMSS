//
//  ExamRoutine.swift
//  MMIHS
//
//  Created by Frost on 3/30/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class ExamRoutine: NSObject {
    
    var eId,sId,sName,eName,eDate,startTime,endTime:String
    
    init(eId:String,sId:String,sName:String,eName:String,eDate:String,startTime:String,endTime:String){
        self.eId = eId
        self.sId = sId
        self.sName = sName
        self.eName = eName
        self.eDate = eDate
        self.startTime = startTime
        self.endTime = endTime
    }

}
