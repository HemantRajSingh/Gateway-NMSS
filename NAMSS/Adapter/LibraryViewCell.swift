//
//  LibraryViewCell.swift
//  MMIHS
//
//  Created by Frost on 4/15/19.
//  Copyright © 2019 Hemant Raj  Singh. All rights reserved.
//

import UIKit

class LibraryViewCell: UITableViewCell {

    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtAuthor: UILabel!
    @IBOutlet weak var txtPublisher: UILabel!
    @IBOutlet weak var txtAvailable: UILabel!
    @IBOutlet weak var txtIssued: UILabel!
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
