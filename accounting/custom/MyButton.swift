//
//  MyButton.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2023/9/15.
//

import UIKit

protocol MyButtonDelegate: AnyObject {
    func myButtonWillEndContextMenuInteraction()
}

class MyButton: UIButton {
    
    
    weak var delegate: MyButtonDelegate?

    // 關閉 Button 的 Menu 時會觸發的
    override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        super.contextMenuInteraction(interaction, willEndFor: configuration, animator: animator)
        print("ending!")
        
        // 告知代理要執行操作
        delegate?.myButtonWillEndContextMenuInteraction()
    }
    
}
