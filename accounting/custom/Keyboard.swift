//
//  Keyboard.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/5/5.
//

import UIKit

protocol KeyboardDelegate: AnyObject {
    
    // 輸入 按鈕數字
    func keyWasTapped(character: String)
    // 刪除 數字
    func deletTapped()
    // 刪除 全部數字
    func deletAllTapped()
    // 相加 按鍵
    func plusTapped()
    // 相乘 按鍵
    func multiplicationTapped()
    // 相減 按鍵
    func deductTapped()
    // 相除 按鍵
    func divisionTapped()
    // 計算 按鍵
    func calculateTapped()
    
}

class Keyboard: UIView {

    // This variable will be set as the view controller so that
    // the keyboard can send messages to the view controller.
    weak var delegate: KeyboardDelegate?

    // MARK:- keyboard initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    func initializeSubviews() {
        let xibFileName = "Keyboard" // xib extention not included
        
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as! UIView
        
        self.addSubview(view)
        view.frame = self.bounds
    }

    // MARK:- Button actions from .xib file
    // 輸入按鈕 事件
    @IBAction func keyTapped(sender: UIButton) {
        // When a button is tapped, send that information to the
        // delegate (ie, the view controller)
        self.delegate?.keyWasTapped(character: sender.titleLabel!.text!) // could alternatively send a tag value
    }
    
    // delet 事件
    @IBAction func keyDelet(sender: UIButton) {
        self.delegate?.deletTapped() // could alternatively send a tag value
    }
    
    // deletAll 事件
    @IBAction func keyDeletAll(sender: UIButton) {
        self.delegate?.deletAllTapped() // could alternatively send a tag value
    }
    
    // plus 事件
    @IBAction func  keyplus(sender: UIButton) {
        self.delegate?.plusTapped() // could alternatively send a tag value
    }
    
    // multiplication 事件
    @IBAction func  keymultiplication(sender: UIButton) {
        self.delegate?.multiplicationTapped() // could alternatively send a tag value
    }
    
    // deduct 事件
    @IBAction func  keydeduct(sender: UIButton) {
        self.delegate?.deductTapped() // could alternatively send a tag value
    }
    
    // division 事件
    @IBAction func  keydivision(sender: UIButton) {
        self.delegate?.divisionTapped() // could alternatively send a tag value
    }
    
    // calculate 事件
    @IBAction func  keycalculate(sender: UIButton) {
        self.delegate?.calculateTapped() // could alternatively send a tag value
    }
    
    
    
    
    

}
