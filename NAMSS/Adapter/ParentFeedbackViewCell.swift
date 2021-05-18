//
//  ParentFeedbackViewCell.swift
//  MMIHS
//
//  Created by Hemant Raj  Singh on 12/28/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class ParentFeedbackViewCell: UITableViewCell {

    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDesc: UILabel!
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var txtResponseDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
