//
//  Event.swift
//  MMIHS
//
//  Created by Frost on 3/30/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Event: NSObject {
    
    var id,name,desc,date,imageUrl : String
    
    init(id:String,name:String,desc:String,date:String,imageUrl:String){
        self.id = id
        self.name = name
        self.desc = desc
        self.date = date
        self.imageUrl = imageUrl
    }

}
