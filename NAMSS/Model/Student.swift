//
//  Student.swift
//  MMIHS
//
//  Created by Frost on 4/7/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Student: NSObject {
    
    var studentId,studentName,section,roll,date,status,staffId,staffName:String
    init(studentId:String,studentName:String,section:String,roll:String,date:String,status:String,staffId:String,staffName:String){
        self.studentId = studentId
        self.studentName = studentName
        self.section = section
        self.roll = roll
        self.date = date
        self.status = status
        self.staffId = staffId
        self.staffName = staffName
    }

}
