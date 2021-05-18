//
//  MessageViewCell.swift
//  MMIHS
//
//  Created by Frost on 5/26/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {

    @IBOutlet weak var imgImage: UIImageView!
    @IBOutlet weak var txtname: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
