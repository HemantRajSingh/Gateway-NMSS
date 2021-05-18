//
//  InvoiceViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/16/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class InvoiceViewCell: UITableViewCell {

    @IBOutlet weak var txtMonth: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtInvoiceNo: UILabel!
    @IBOutlet weak var txtBilledMonth: UILabel!
    @IBOutlet weak var txtTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
