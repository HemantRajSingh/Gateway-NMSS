//
//  OnlineClassSectionHeader.swift
//  NAMSS
//
//  Created by ITH on 17/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit

class OnlineClassSectionHeader: NSObject {
    
    var opened : Bool
    var title : String
    var sectionData : [OnlineClass]
    
    init(opened:Bool,title:String,sectionData:[OnlineClass]){
        self.opened = opened
        self.title = title
        self.sectionData = sectionData
    }

}

