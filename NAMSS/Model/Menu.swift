//
//  Menu.swift
//  MMIHS
//
//  Created by Frost on 3/14/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Menu: NSObject {
    
    let menuId : Int
    let view : String
    let menuImage : UIImage
    let menuTitle : String
    let menuDesc : String
    
    init(menuId:Int, view:String, menuImage : UIImage, menuTitle:String,menuDesc:String) {
        self.menuId = menuId
        self.view = view
        self.menuImage = menuImage
        self.menuTitle = menuTitle
        self.menuDesc = menuDesc
    }

}
