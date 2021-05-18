//
//  FrontPageSectionHeader.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 9/24/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class FrontPageSectionHeader: NSObject {
    
    var opened : Bool
    var title : String
    var sectionData : [FrontPage]
    
    init(opened:Bool,title:String,sectionData:[FrontPage]){
        self.opened = opened
        self.title = title
        self.sectionData = sectionData
    }

}
