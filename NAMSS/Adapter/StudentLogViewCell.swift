//
//  StudentLogViewCell.swift
//  MMIHS
//
//  Created by Frost on 5/26/19.
//  Copyright © 2019 MMIHS. All rights reserved.
//

import UIKit

class StudentLogViewCell: UITableViewCell {

    @IBOutlet weak var txtSerial: UILabel!
    @IBOutlet weak var txtFaculty: UILabel!
    @IBOutlet weak var txtProgram: UILabel!
    @IBOutlet weak var txtClass: UILabel!
    @IBOutlet weak var txtPresent: UILabel!
    @IBOutlet weak var txtAbsent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
