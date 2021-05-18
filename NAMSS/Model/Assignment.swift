//
//  Assignment.swift
//  SchoolApp
//
//  Created by Hemant Raj  Singh on 2/19/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import Foundation

class Assignment{

    var classId, subjectId,sectionId,subjectName,homeworkDate,homeworkDescription,teacherId,teacherName: String;
    
    public init(classId:String, subjectId:String,sectionId:String,subjectName:String,homeworkDate:String,homeworkDescription:String,teacherId:String,teacherName: String){
        self.classId = classId;
        self.subjectId = subjectId;
        self.sectionId = sectionId;
        self.subjectName = subjectName;
        self.homeworkDate = homeworkDate;
        self.homeworkDescription = homeworkDescription;
        self.teacherId = teacherId;
        self.teacherName = teacherName;
    }
    
}
