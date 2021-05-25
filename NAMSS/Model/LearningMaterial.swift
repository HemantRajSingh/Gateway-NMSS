//
//  LearningMaterial.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit

class LearningMaterial {
    
    var facultyName,programmeName,className,subjectName,submitBy,documentTitle,documentUrl,materialType,remarks : String
    
    init(facultyName:String,programmeName:String,className:String,subjectName:String,submitBy:String,documentTitle:String,documentUrl:String,materialType:String,remarks:String){
        self.facultyName = facultyName
        self.programmeName = programmeName
        self.className = className
        self.subjectName = subjectName
        self.submitBy = submitBy
        self.documentTitle = documentTitle
        self.documentUrl = documentUrl
        self.materialType = materialType
        self.remarks = remarks
    }

}
