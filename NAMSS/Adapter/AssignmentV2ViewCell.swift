//
//  AssignmentV2ViewCell.swift
//  NAMSS
//
//  Created by ITH on 25/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit

class AssignmentV2ViewCell: UITableViewCell {
    
    @IBOutlet weak var txtSubjectName: UILabel!
    @IBOutlet weak var txtDeadline: UILabel!
    @IBOutlet weak var txtRemarks: UILabel!
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
