//
//  PaymentViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/16/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class PaymentViewCell: UITableViewCell {

    
    @IBOutlet weak var txtMonth: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtFeeType: UILabel!
    @IBOutlet weak var txtFiscalYear: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
