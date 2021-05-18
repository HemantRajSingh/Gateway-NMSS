//
//  Contact.swift
//  MMIHS
//
//  Created by Frost on 4/13/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var name,dep,des,mobile:String
    
    init(name:String,dep:String,des:String,mobile:String){
    self.name = name
    self.dep = dep
    self.des = des
    self.mobile = mobile
    }
}
