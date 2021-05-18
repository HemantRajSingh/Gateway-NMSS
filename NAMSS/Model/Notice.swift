//
//  Notice.swift
//  MMIHS
//
//  Created by Frost on 3/23/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Notice: NSObject {
    
    let day,date,type,title,desc,imageUrl,duration : String
    
    init(day:String,date:String,type:String,title:String,desc:String,imageUrl:String,duration:String){
        self.day = day
        self.date = date
        self.type = type
        self.title = title
        self.desc = desc
        self.imageUrl = imageUrl
        self.duration = duration
    }

}
