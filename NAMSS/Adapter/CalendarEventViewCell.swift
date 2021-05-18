//
//  CalendarEventViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/27/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class CalendarEventViewCell: UITableViewCell {

    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDesc: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
