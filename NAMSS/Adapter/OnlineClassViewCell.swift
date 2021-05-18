//
//  OnlineClassViewCell.swift
//  NAMSS
//
//  Created by ITH on 16/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit

class OnlineClassViewCell: UITableViewCell {
    
    
    @IBOutlet weak var txtSubjectName: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtClassName: UILabel!
    @IBOutlet weak var txtStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
