//
//  FrontPage.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 9/24/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class FrontPage: NSObject {
    
    let notifType,notifDuration,notifDate,notifTitle,notifDesc,imageUrl,notifGroup : String
    
    init(notifType:String,notifDuration:String,notifDate:String,notifTitle:String,notifDesc:String,imageUrl:String,notifGroup:String){
        self.notifType = notifType
        self.notifDuration = notifDuration
        self.notifDate = notifDate
        self.notifTitle = notifTitle
        self.notifDesc = notifDesc
        self.imageUrl = imageUrl
        self.notifGroup = notifGroup
    }

}
