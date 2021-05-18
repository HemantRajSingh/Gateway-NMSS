//
//  MessageView.swift
//  MMIHS
//
//  Created by Frost on 5/26/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class MessageView: NSObject {
    
    var teacherName = "",subject = "",message = "",date = ""
    
    init(teacherName:String,subject:String,message:String,date:String) {
        self.teacherName = teacherName
        self.subject = subject
        self.message = message
        self.date = date
    }

}
