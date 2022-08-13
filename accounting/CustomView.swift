//
//  CustomView.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/7/17.
//

import UIKit

class CustomView: UIView {

    let segmentedControl: UISegmentedControl = {
            let items = ["Now","In 15 mins", "In 1 hour"]
            let sc = UISegmentedControl(items: items)
            sc.selectedSegmentIndex = 0
            return sc
      }()

    let fetchingLabel: UILabel = {
           let label = UILabel(frame: .zero)
           label.text = "Fetching..."
           return label
      }()

}
