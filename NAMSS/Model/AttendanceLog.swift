//
//  AttendanceLog.swift
//  MMIHS
//
//  Created by Frost on 3/30/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class AttendanceLog: NSObject {
    
    var studentId,studentName,className,departmentName,facultyName : String
    
    init(studentId:String,studentName:String,className:String,departmentName:String,facultyName:String){
        self.studentId = studentId
        self.studentName = studentName
        self.className = className
        self.departmentName = departmentName
        self.facultyName = facultyName
    }

}
