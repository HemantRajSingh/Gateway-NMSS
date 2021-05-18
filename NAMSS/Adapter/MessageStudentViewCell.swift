//
//  MessageStudentViewCell.swift
//  MMIHS
//
//  Created by Frost on 5/25/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class MessageStudentViewCell: UITableViewCell {

    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var switchPresent: UISwitch!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
