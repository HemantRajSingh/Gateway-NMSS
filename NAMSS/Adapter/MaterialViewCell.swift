//
//  MaterialViewCell.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit

class MaterialViewCell: UITableViewCell {
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtType: UILabel!
    @IBOutlet weak var txtSubject: UILabel!
    @IBOutlet weak var txtSubmitBy: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var imgDownload: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
