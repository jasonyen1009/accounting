//
//  accountingTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/4/19.
//

import UIKit

class accountingTableViewController: UITableViewController {
    
    @IBOutlet var textfieldCollection: [UITextField]!
    @IBOutlet var Labelcollection: [UILabel]!
    @IBOutlet var clearButtonCollection: [UIButton]!
        
    // 總資料
    var editaccount = Spending(personal: 0, dietary: 0, shopping: 0, traffic: 0, medical: 0, life: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: (view.frame.height) * 2 / 6))
        keyboardView.delegate = self
        
        // 設定全部的 textfield 的 inputview
        for textfield in textfieldCollection {
            textfield.inputView = keyboardView
        }
                                    

        updateUI()
        // textfield tool
        // 暫時取消
//        addToolBarOnKeyboard()

//        print(editaccount)
        
//         self.navigationItem.rightBarButtonItem = self.editButtonItem

        // 禁止下拉
        self.isModalInPresentation = true
    }
    
    // 新增各種工具在 TextField 上
    func addToolBarOnKeyboard() {
        
        for (index, TextField) in textfieldCollection.enumerated() {
            // ToolBar 製作
            let ToolBar = UIToolbar()
            ToolBar.sizeToFit()
            
            // 製作 previous 按鍵
            let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
            // 製作 next 按鍵
            let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
            
            // 製作 plus 按鍵
            let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: nil, action: #selector(plusmoney))
            
            // 製作 deduct 按鍵
            let deductButton = UIBarButtonItem(image: UIImage(systemName: "minus.circle"), style: .plain, target: nil, action: #selector(deductmoney))
            
            // 製作 空白 按鍵
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            ToolBar.setItems([previousButton, nextButton, flexibleSpace, plusButton, deductButton], animated: true)
            TextField.inputAccessoryView = ToolBar
            
            //判斷是否為第一個 TextField
            if TextField == textfieldCollection.first {
                //關閉 previous 按鍵
                previousButton.isEnabled = false
            }else {
                previousButton.target = textfieldCollection[index - 1]
                previousButton.action = #selector(TextField.becomeFirstResponder)
            }
            
            //判斷是否為最後一個 TextField
            if TextField == textfieldCollection.last {
                //關閉 next 按鍵
                nextButton.isEnabled = false
            }else {
                nextButton.target = textfieldCollection[index + 1]
                nextButton.action = #selector(TextField.becomeFirstResponder)
            }
        }
    }
    
    //收鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //done 收鍵盤
    @objc func savemoney() {
        
        updateTextField()
//        view.endEditing(true)
    }
    
    // clear account
    @objc func clearmony() {
        
        if textfieldCollection[0].becomeFirstResponder() {
            editaccount.personal = 0
            Labelcollection[0].text = "個人：\(editaccount.personal)"
            textfieldCollection[0].text = ""
        }else if textfieldCollection[1].becomeFirstResponder() {
                editaccount.dietary = 0
                Labelcollection[1].text = "飲食：\(editaccount.dietary)"
                textfieldCollection[1].text = ""
        }
    }
    
    // plus account
    @objc func plusmoney() {
        
        editaccount.personal += Int(textfieldCollection[0].text!) ?? 0
        Labelcollection[0].text = "個人：\(moneyString(editaccount.personal))"
        textfieldCollection[0].text = ""
        
        editaccount.dietary += Int(textfieldCollection[1].text!) ?? 0
        Labelcollection[1].text = "飲食：\(moneyString(editaccount.dietary))"
        textfieldCollection[1].text = ""
        
        editaccount.shopping += Int(textfieldCollection[2].text!) ?? 0
        Labelcollection[2].text = "購物：\(moneyString(editaccount.shopping))"
        textfieldCollection[2].text = ""
        
        editaccount.traffic += Int(textfieldCollection[3].text!) ?? 0
        Labelcollection[3].text = "交通：\(moneyString(editaccount.traffic))"
        textfieldCollection[3].text = ""
        
        editaccount.medical += Int(textfieldCollection[4].text!) ?? 0
        Labelcollection[4].text = "醫療：\(moneyString(editaccount.medical))"
        textfieldCollection[4].text = ""
        
        editaccount.life += Int(textfieldCollection[5].text!) ?? 0
        Labelcollection[5].text = "生活：\(moneyString(editaccount.life))"
        textfieldCollection[5].text = ""
        
    }
    
    // deduct account
    @objc func deductmoney() {
        
        editaccount.personal -= Int(textfieldCollection[0].text!) ?? 0
        if editaccount.personal < 0 {
            editaccount.personal = 0
        }
        Labelcollection[0].text = "個人：\(moneyString(editaccount.personal))"
        textfieldCollection[0].text = ""
        
        editaccount.dietary -= Int(textfieldCollection[1].text!) ?? 0
        if editaccount.dietary < 0 {
            editaccount.dietary = 0
        }
        Labelcollection[1].text = "飲食：\(moneyString(editaccount.dietary))"
        textfieldCollection[1].text = ""
        
        editaccount.shopping -= Int(textfieldCollection[2].text!) ?? 0
        if editaccount.shopping < 0 {
            editaccount.shopping = 0
        }
        Labelcollection[2].text = "購物：\(moneyString(editaccount.shopping))"
        textfieldCollection[2].text = ""
        
        editaccount.traffic -= Int(textfieldCollection[3].text!) ?? 0
        if editaccount.traffic < 0 {
            editaccount.traffic = 0
        }
        Labelcollection[3].text = "交通：\(moneyString(editaccount.traffic))"
        textfieldCollection[3].text = ""
        
        editaccount.medical -= Int(textfieldCollection[4].text!) ?? 0
        if editaccount.medical < 0 {
            editaccount.medical = 0
        }
        Labelcollection[4].text = "醫療：\(moneyString(editaccount.medical))"
        textfieldCollection[4].text = ""
        
        editaccount.life -= Int(textfieldCollection[5].text!) ?? 0
        if editaccount.life < 0 {
            editaccount.life = 0
        }
        Labelcollection[5].text = "生活：\(moneyString(editaccount.life))"
        textfieldCollection[5].text = ""
        
    }
    

    

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 更新畫面
    func updateUI() {
        
        Labelcollection[0].text = "個人：\(moneyString(editaccount.personal))"
        Labelcollection[1].text = "飲食：\(moneyString(editaccount.dietary))"
        Labelcollection[2].text = "購物：\(moneyString(editaccount.shopping))"
        Labelcollection[3].text = "交通：\(moneyString(editaccount.traffic))"
        Labelcollection[4].text = "醫療：\(moneyString(editaccount.medical))"
        Labelcollection[5].text = "生活：\(moneyString(editaccount.life))"
        // 判斷資料是否為 0, 若為 0 改為空白字串
//        for i in 0...5 {
//            if textfieldCollection[i].text == "0" {
//                textfieldCollection[i].text = ""
//            }
//        }
        
    }
    
    // 暫時無用到
    func updateTextField() {
        editaccount.personal = Int(textfieldCollection[0].text!) ?? 0
        editaccount.dietary = Int(textfieldCollection[1].text!) ?? 0
        editaccount.shopping = Int(textfieldCollection[2].text!) ?? 0
        editaccount.traffic = Int(textfieldCollection[3].text!) ?? 0
        editaccount.medical = Int(textfieldCollection[4].text!) ?? 0
        editaccount.life = Int(textfieldCollection[5].text!) ?? 0
        print(editaccount)
    }
    
    // 將 tableView 的 HeaderInSection 高度設為 0
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    // 將 tableView 的 FooterInSection 高度設為 0
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    
    @IBAction func saveaccount(_ sender: UIButton) {
//        if sender == clearButtonCollection[0] {
//            print("get one")
//        }else {
//            print("get second")
//        }
        
        // 製作警視窗，避免誤觸刪除按鈕
        let alertController = UIAlertController(title: "是否要刪除本欄累積金額🥺", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            switch sender {
            case self.clearButtonCollection[0]:
                self.editaccount.personal = 0
                self.Labelcollection[0].text = "個人：\(self.moneyString(self.editaccount.personal))"
                self.textfieldCollection[0].text = ""
                
            case self.clearButtonCollection[1]:
                self.editaccount.dietary = 0
                self.Labelcollection[1].text = "飲食：\(self.moneyString(self.editaccount.dietary))"
                self.textfieldCollection[1].text = ""
                
            case self.clearButtonCollection[2]:
                self.editaccount.shopping = 0
                self.Labelcollection[2].text = "購物：\(self.moneyString(self.editaccount.shopping))"
                self.textfieldCollection[2].text = ""
                
            case self.clearButtonCollection[3]:
                self.editaccount.traffic = 0
                self.Labelcollection[3].text = "交通：\(self.moneyString(self.editaccount.traffic))"
                self.textfieldCollection[3].text = ""
                
            case self.clearButtonCollection[4]:
                self.editaccount.medical = 0
                self.Labelcollection[4].text = "醫療：\(self.moneyString(self.editaccount.medical))"
                self.textfieldCollection[4].text = ""
                
            default:
                self.editaccount.life = 0
                self.Labelcollection[5].text = "生活：\(self.moneyString(self.editaccount.life))"
                self.textfieldCollection[5].text = ""
            
            }
        }))
        present(alertController, animated: true)
    }
    
    // 數字轉為金錢格式文字
    func moneyString(_ money: Int) -> String{
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: money)) ?? ""
    }
    
}

extension accountingTableViewController: KeyboardDelegate {
    func keyWasTapped(character: String) {
        print("hi")
    }
    
    func deletTapped() {
        print("hi")

    }
    
    func deletAllTapped() {
        print("hi")

    }
    
    func plusTapped() {
        print("hi")

    }
    
    func multiplicationTapped() {
        print("hi")

    }
    
    func deductTapped() {
        print("hi")

    }
    
    func divisionTapped() {
        print("hi")

    }
    
    func calculateTapped() {
        print("hi")

    }
    
    
}
