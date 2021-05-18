//
//  SectionHeader.swift
//  MMIHS
//
//  Created by Frost on 4/21/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class SectionHeader: NSObject {
    
    var opened : Bool
    var title : String
    var sectionData : [Notice]
    
    init(opened:Bool,title:String,sectionData:[Notice]){
        self.opened = opened
        self.title = title
        self.sectionData = sectionData
    }

}
