//
//  ExpensetypeTableViewCell.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/6/3.
//

import UIKit

class ExpensetypeTableViewCell: UITableViewCell {

    @IBOutlet weak var expensetypeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var circleview: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
