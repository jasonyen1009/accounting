//
//  ExpenseListTableViewCell.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/6/4.
//

import UIKit

class ExpenseListTableViewCell: UITableViewCell {

    @IBOutlet weak var accountimageview: UIImageView!
    @IBOutlet weak var expensenameLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
