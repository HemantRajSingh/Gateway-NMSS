//
//  Library.swift
//  MMIHS
//
//  Created by Frost on 4/15/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Library: NSObject {
    
    var id,name,author,a1,a2,publisher,circularBookCount,issuedBookCount,availableBookCount,edition,publishedYear:String
    
    init(id:String,name:String,author:String,a1:String,a2:String,publisher:String,circularBookCount:String,issuedBookCount:String,availableBookCount:String,edition:String,publishedYear:String){
        self.id = id
        self.name = name
        self.author = author
        self.a1 = a1
        self.a2 = a2
        self.publisher = publisher
        self.circularBookCount = circularBookCount
        self.issuedBookCount = issuedBookCount
        self.availableBookCount = availableBookCount
        self.edition = edition
        self.publishedYear = publishedYear
    }

}
