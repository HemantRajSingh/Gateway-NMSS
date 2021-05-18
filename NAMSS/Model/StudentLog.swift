//
//  StudentLog.swift
//  MMIHS
//
//  Created by Frost on 5/26/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class StudentLog: NSObject {
    
    var serial = "", faculty = "", program = "", year = ""
    var presentStudent = [NewStudentLog]()
    var absentStudent = [NewStudentLog]()
    init(serial:String,faculty:String,program:String,year:String,presentStudent:[NewStudentLog],absentStudent:[NewStudentLog]){
        self.serial = serial
        self.faculty = faculty
        self.program = program
        self.year = year
        self.presentStudent = presentStudent
        self.absentStudent = absentStudent
    }

}
