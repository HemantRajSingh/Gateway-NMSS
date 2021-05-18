//
//  ClassRoutineViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/21/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class ClassRoutineViewCell: UITableViewCell {

    @IBOutlet weak var txtTime: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtStaffName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
