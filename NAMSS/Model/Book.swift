//
//  Book.swift
//  MMIHS
//
//  Created by Frost on 3/30/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class Book: NSObject {

    var bookCatalogId,bookName,author,author1,author2,publisher,circularBookCount,issuedBookCount,availableBookCount,edition,publishedYear : String
    
    init(bookCatalogId:String,bookName:String,author:String,author1:String,author2:String,publisher:String,circularBookCount:String,issuedBookCount:String,availableBookCount:String,edition:String,publishedYear:String){
        self.bookCatalogId = bookCatalogId
        self.bookName = bookName
        self.author = author
        self.author1 = author1
        self.author2 = author2
        self.publisher = publisher
        self.circularBookCount = circularBookCount
        self.issuedBookCount = issuedBookCount
        self.availableBookCount = availableBookCount
        self.edition = edition
        self.publishedYear = publishedYear
    }
    
}
