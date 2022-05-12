//
//  CustomButton.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/5/5.
//

import UIKit

class CustomButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 37/255, green: 40/255, blue: 48/255, alpha: 1) : UIColor(red: 43/255, green: 49/255, blue: 56/255, alpha: 1)
        }
    }

}
