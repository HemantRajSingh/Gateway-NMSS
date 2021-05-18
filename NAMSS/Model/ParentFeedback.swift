//
//  ParentFeedback.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 12/28/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class ParentFeedback: NSObject {
    
    var id = "", userid = "", studentname = "", facultyname = "", departmentName = "", className = "", batchName = "", registerDateNp = "", registerDateEn = "", staffName = "", feedbackDetail = "", feedbackImageUrl = "", feedbackStatus = "", feedbackResponseBy = "", feedbackResponseDateNp = "", feedbackResponseDateEn = "", feedbackResponseDetail = ""
    init(id:String, userid:String, studentname:String, facultyname:String, departmentName:String, className:String, batchName:String, registerDateNp:String, registerDateEn:String, staffName:String, feedbackDetail:String, feedbackImageUrl:String, feedbackStatus :String, feedbackResponseBy:String, feedbackResponseDateNp:String, feedbackResponseDateEn:String, feedbackResponseDetail:String){
        self.id = id
        self.userid = userid
        self.studentname = studentname
        self.facultyname = facultyname
        self.departmentName = departmentName
        self.className = className
        self.batchName = batchName
        self.registerDateNp = registerDateNp
        self.registerDateEn = registerDateEn
        self.staffName = staffName
        self.feedbackDetail = feedbackDetail
        self.feedbackImageUrl = feedbackImageUrl
        self.feedbackStatus = feedbackStatus
        self.feedbackResponseBy = feedbackResponseBy
        self.feedbackResponseDateNp = feedbackResponseDateNp
        self.feedbackResponseDateEn = feedbackResponseDateEn
        self.feedbackResponseDetail = feedbackResponseDetail
    }
    
    override init(){
        
    }
}
