//
//  AssignmentV2.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import Foundation

class AssignmentV2 {
    
    var homeworkId, className,subjectName,homeworkDateEn,homeworkDate,homeworkDescription,teacherName,imageUrl,submissionDateEn,submissionDate,status: String;
    
    public init(homeworkId:String, className:String,subjectName:String,homeworkDateEn:String,homeworkDate:String,homeworkDescription:String,teacherName: String,imageUrl:String,submissionDateEn:String,submissionDate:String,status:String){
        self.homeworkId = homeworkId;
        self.className = className;
        self.subjectName = subjectName;
        self.homeworkDateEn = homeworkDateEn;
        self.homeworkDate = homeworkDate;
        self.homeworkDescription = homeworkDescription;
        self.teacherName = teacherName;
        self.imageUrl = imageUrl;
        self.submissionDateEn = submissionDateEn;
        self.submissionDate = submissionDate;
        self.status = status;
    }

}
