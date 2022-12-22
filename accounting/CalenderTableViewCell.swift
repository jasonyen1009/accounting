//
//  CalenderTableViewCell.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2022/12/17.
//

import UIKit

class CalenderTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellnameLabel: UILabel!
    @IBOutlet weak var cellmoneyLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
