//
//  AssignmenV2SectionHeader.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import Foundation

class AssignmentV2SectionHeader: NSObject {
    
    var opened : Bool
    var title : String
    var sectionData : [AssignmentV2]
    
    init(opened:Bool,title:String,sectionData:[AssignmentV2]){
        self.opened = opened
        self.title = title
        self.sectionData = sectionData
    }

}
