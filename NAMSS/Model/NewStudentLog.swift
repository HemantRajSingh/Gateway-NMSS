//
//  NewStudentLog.swift
//  MMIHS
//
//  Created by Frost on 5/26/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class NewStudentLog: NSObject {
    
    var id = "", name = "", classId = "", className = "", depId = "", depName = "", facId = "", facName = "", mobile = ""
    
    init(id:String, name:String, classId:String, className:String, depId:String, depName:String, facId:String, facName:String, mobile:String){
        self.id = id
        self.name = name
        self.classId = classId
        self.className = className
        self.depId = depId
        self.depName = depName
        self.facId = facId
        self.facName = facName
        self.mobile = mobile
    }

}
