//
//  EventDetailVC.swift
//  MMIHS
//
//  Created by Frost on 5/22/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class EventDetailVC: UIViewController {

    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDesc: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnDone(_ sender: Any) {
        self.view.removeFromSuperview()
            self.removeFromParent()
    }

}
