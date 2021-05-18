//
//  LeaveViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/12/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class LeaveViewCell: UITableViewCell {
    
    
    @IBOutlet weak var txtDay: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtFromTo: UILabel!
    @IBOutlet weak var txtDuration: UILabel!
    @IBOutlet weak var txtStatus: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
