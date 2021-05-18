//
//  ProfileViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/20/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class ProfileViewCell: UITableViewCell {
    
    
    @IBOutlet weak var txtName: UILabel!
    
    @IBOutlet weak var txtDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
