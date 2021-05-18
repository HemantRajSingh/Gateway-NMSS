//
//  Result.swift
//  MMIHS
//
//  Created by Frost on 4/13/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Result: NSObject {
    
    var subject,fullMarkTheory,fullMarkPractical,obtainedMark,obtainedTheoryMark,obtainedPracticalMark,highestMark,highestTheoryMark,highestPracticalMark,rank,gpa,grade:String
    
    init(subject:String,fullMarkTheory:String,fullMarkPractical:String,obtainedMark:String,obtainedTheoryMark:String,obtainedPracticalMark:String,highestMark:String,highestTheoryMark:String,highestPracticalMark:String,rank:String,gpa:String,grade:String){
        self.subject = subject
        self.fullMarkTheory = fullMarkTheory
        self.fullMarkPractical = fullMarkPractical
        self.obtainedMark = obtainedMark
        self.obtainedTheoryMark = obtainedTheoryMark
        self.obtainedPracticalMark = obtainedPracticalMark
        self.highestMark = highestMark
        self.highestTheoryMark = highestTheoryMark
        self.highestPracticalMark = highestPracticalMark
        self.rank = rank
        self.gpa = gpa
        self.grade = grade
    }

}
