//
//  AttendanceViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/7/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class AttendanceViewCell: UITableViewCell {
    
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var switchPresent: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
