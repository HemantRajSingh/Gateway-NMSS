//
//  AssignmentContent.swift
//  NAMSS
//
//  Created by ITH on 26/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import Foundation

class AssignmentContent {
    var assignmentId,studentUserId,studentId,homeworkId,submissionDate,studentName,className,sectionName,homeworkName,remarks,teacherMarks,teacherUserId,teacherFeedbackDate: String
    var filesList = [String]()
    
    init(){
        self.assignmentId = ""
        self.studentUserId = ""
        self.studentId = ""
        self.homeworkId = ""
        self.submissionDate = ""
        self.studentName = ""
        self.className = ""
        self.sectionName = ""
        self.homeworkName = ""
        self.remarks = ""
        self.teacherMarks = ""
        self.teacherUserId = ""
        self.teacherFeedbackDate = ""
        self.filesList = [String]()
    }
    
    public init(assignmentId:String,studentUserId:String,studentId:String,homeworkId:String,submissionDate:String,studentName:String,className:String,sectionName:String,homeworkName:String,remarks:String,teacherMarks:String,teacherUserId:String,teacherFeedbackDate:String,filesList:[String]){
        self.assignmentId = assignmentId
        self.studentUserId = studentUserId
        self.studentId = studentId
        self.homeworkId = homeworkId
        self.submissionDate = submissionDate
        self.studentName = studentName
        self.className = className
        self.sectionName = sectionName
        self.homeworkName = homeworkName
        self.remarks = remarks
        self.teacherMarks = teacherMarks
        self.teacherUserId = teacherUserId
        self.teacherFeedbackDate = teacherFeedbackDate
        self.filesList = filesList
    }
    
}
