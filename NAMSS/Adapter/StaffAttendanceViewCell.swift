//
//  StaffAttendanceViewCell.swift
//  MMIHS
//
//  Created by Frost on 6/1/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class StaffAttendanceViewCell: UITableViewCell {

    @IBOutlet weak var txtTime: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtDepartment: UILabel!
    @IBOutlet weak var txtDesignation: UILabel!
    @IBOutlet weak var txtShift: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
