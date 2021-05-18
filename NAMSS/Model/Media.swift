//
//  Media.swift
//  MMIHS
//
//  Created by Frost on 6/22/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class Media: NSObject {
    
    var id,title,desc,url,type,status,group,date,thumbnail:String
    
    init(id:String,title:String,desc:String,url:String,type:String,status:String,group:String,date:String,thumbnail:String){
        self.id = id
        self.title = title
        self.desc = desc
        self.url = url
        self.type = type
        self.status = status
        self.group = group
        self.date = date
        self.thumbnail = thumbnail
    }

}
