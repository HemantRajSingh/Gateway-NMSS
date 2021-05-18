//
//  OnlineClass.swift
//  NAMSS
//
//  Created by ITH on 16/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import Foundation

class OnlineClass{

    var id, joiningLink,status,subjectId,subjectName,teacherId,classId,className, classCompletedTime, classRunningTime, classStartDate, createdBy, createdDate: String;
    
    public init(id: String, joiningLink: String,status: String,subjectId: String,subjectName: String,teacherId: String,classId: String,className: String, classCompletedTime: String, classRunningTime: String, classStartDate: String, createdBy: String, createdDate: String){
        self.id = id;
        self.joiningLink = joiningLink;
        self.status = status;
        self.subjectId = subjectId
        self.subjectName = subjectName;
        self.teacherId = teacherId;
        self.classId = classId;
        self.className = className;
        self.classCompletedTime = classCompletedTime;
        self.classRunningTime = classRunningTime;
        self.classStartDate = classStartDate;
        self.createdBy = createdBy;
        self.createdDate = createdDate;
    }
}
