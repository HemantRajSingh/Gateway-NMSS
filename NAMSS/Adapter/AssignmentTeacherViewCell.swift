//
//  AssignmentTeacherViewCell.swift
//  NAMSS
//
//  Created by ITH on 26/05/2021.
//  Copyright © 2021 MMIHS. All rights reserved.
//

import UIKit

class AssignmentTeacherViewCell: UITableViewCell {
    
    @IBOutlet weak var txtClassName: UILabel!
    @IBOutlet weak var txtSubject: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var txtAssignee: UILabel!
    @IBOutlet weak var txtHomeworkDate: UILabel!
    @IBOutlet weak var txtSubmisionDate: UILabel!
    
    @IBOutlet weak var imgAssignment: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
