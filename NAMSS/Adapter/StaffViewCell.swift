//
//  StaffViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/13/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class StaffViewCell: UITableViewCell {

    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtDepartment: UILabel!
    @IBOutlet weak var txtDesignation: UILabel!
    @IBOutlet weak var txtMobile: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
