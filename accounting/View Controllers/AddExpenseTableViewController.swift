//
//  AddExpenseTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/8/10.
//

import UIKit

protocol AddExpenseTableViewControllerDelegate {
    func addExpenseTableViewController(_ controller: AddExpenseTableViewController, didEdit data: Expense)
}

class AddExpenseTableViewController: UITableViewController {

    var mydata: Expense?
    var number1 = 0.0
    var number2 = 0.0
    var calculatetype = ""
    var delegate: AddExpenseTableViewControllerDelegate?
    
    // category
    var category = "個人"
    
    // date
    var now = Date()
    let formatter = DateFormatter()
    var minutes = ""
    
    // 用於模糊化的 UIVisualEffectView
    var blurEffectView: UIVisualEffectView?
    
//    @IBOutlet weak var categorySegmentedcontrol: UISegmentedControl!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var accountSegmentedcontrol: UISegmentedControl!
    @IBOutlet weak var accountnameTextfield: UITextField!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var accountImageview: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var categoryButton: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textfield delegate
        accountnameTextfield.delegate = self
        accountTextfield.delegate = self
        
        // textview delegate
        noteTextView.delegate = self
        
        // categoryButton delegate
        categoryButton.delegate = self
        
        noteTextView.text = "備忘錄"
        // 判斷目前語言是否為英文
        if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
            noteTextView.text = "Note"
        }
        noteTextView.textColor = UIColor.lightGray
        
        // custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: (view.frame.height) * 2 / 6))
        keyboardView.delegate = self
        
        //
        accountTextfield.inputView = keyboardView
                        
        // 抓取目前的時間
        formatter.dateFormat = "HH:mm:ss.SSS"
        let minandsec = formatter.string(from: now)
        minutes = minandsec

        // 設定 button 的 menu 表單
        setButton(categoryButton)
 
    }
    
    //收鍵盤
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    // 更新消費類別圖示
    @IBAction func cahngepayimage(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            accountImageview.image = UIImage(named: "money")
        case 1:
            accountImageview.image = UIImage(named: "credit-card")
        default:
            accountImageview.image = UIImage(named: "bank")
        }
        // 資料即時同步
        delegate?.addExpenseTableViewController(self, didEdit: updatedata())
    }
    
    
    // 更新日期
    @IBAction func changeday(_ sender: UIDatePicker) {
        // 資料即時同步
        delegate?.addExpenseTableViewController(self, didEdit: updatedata())
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
    
    func updatedata() -> Expense {
        formatter.dateFormat = "yyyy/MM/dd"
        let connectdate = "\(formatter.string(from: DatePicker.date)) \(minutes)"
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        
        let sptype = category
        let spname = accountnameTextfield.text ?? ""
        var pytype: String?
        // 判斷 segment 的 index
        switch accountSegmentedcontrol.selectedSegmentIndex {
        case 0:
            pytype = "現金"
        case 1:
            pytype = "信用卡"
        default :
            pytype = "帳戶"
        }
        
        let spending = Int(accountTextfield.text!) ?? 0
        let note = noteTextView.text ?? ""
        mydata = Expense(date: formatter.date(from: connectdate)!, expensetype: sptype, expensename: spname, paytype: pytype!, expense: spending, note: note)
        
        return mydata!
    }
    
    
    func setButton(_ button: UIButton) {
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        
        // 判斷是否為 英文
        if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
            button.menu = UIMenu(children: [
                UIAction(title: "personal",  handler: { [self] action in
                    category = "個人"
                }),
                UIAction(title: "dietary",  handler: { [self] action in
                    category = "飲食"
                }),
                UIAction(title: "shopping",  handler: { [self] action in
                    category = "購物"
                }),
                UIAction(title: "traffic",  handler: { [self] action in
                    category = "交通"
                }),
                UIAction(title: "medical",  handler: { [self] action in
                    category = "醫療"
                }),
                UIAction(title: "life",  handler: { [self] action in
                    category = "生活"
                })
                
            ])
        }else {
            button.menu = UIMenu(children: [
                UIAction(title: "個人",  handler: { [self] action in
                    category = "個人"
                }),
                UIAction(title: "飲食",  handler: { [self] action in
                    category = "飲食"
                }),
                UIAction(title: "購物",  handler: { [self] action in
                    category = "購物"
                }),
                UIAction(title: "交通",  handler: { [self] action in
                    category = "交通"
                }),
                UIAction(title: "醫療",  handler: { [self] action in
                    category = "醫療"
                }),
                UIAction(title: "生活",  handler: { [self] action in
                    category = "生活"
                })
            ])
        }
        
        // 在按下 button 時顯示模糊背景
        button.addTarget(self, action: #selector(showBlurBackground), for: .menuActionTriggered)
        
    }

    
    @objc func showBlurBackground() {
        // 創建模糊效果
        let blurEffect = UIBlurEffect(style: .light) // 這裡可以根據需要選擇模糊風格
        // 創建模糊視圖
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = UIScreen.main.bounds
        view.addSubview(blurEffectView!)
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    

    
    

}

extension AddExpenseTableViewController: KeyboardDelegate {
    
    func keyWasTapped(character: String) {
        accountTextfield.insertText(character)
    }
    
    func deletTapped() {
        accountTextfield.deleteBackward()

    }
    
    func deletAllTapped() {
        accountTextfield.text?.removeAll()

    }
    
    func plusTapped() {
        if let number = accountTextfield.text {
            number1 = Double(number) ?? 0
            accountTextfield.text?.removeAll()
        }
        calculatetype = "+"
    }
    
    func multiplicationTapped() {
        if let number = accountTextfield.text {
            number1 = Double(number) ?? 0
            accountTextfield.text?.removeAll()
        }
        calculatetype = "X"
    }
    
    func deductTapped() {
        if let number = accountTextfield.text {
            number1 = Double(number) ?? 0
            accountTextfield.text?.removeAll()
        }
        calculatetype = "-"
    }
    
    func divisionTapped() {
        if let number = accountTextfield.text {
            number1 = Double(number) ?? 0
            accountTextfield.text?.removeAll()
        }
        calculatetype = "/"
    }
    
    func calculateTapped() {
        if let number = accountTextfield.text {
            number2 = Double(number) ?? 0
            switch calculatetype{
            case "+":
                accountTextfield.text = String(number1 + number2)
            case "X":
                accountTextfield.text = String(number1 *  number2)
            case "-":
                accountTextfield.text = String(number1 -  number2)
            case "/":
                accountTextfield.text = String(number1 /  number2)
            default :
                print("")
            }
            number1 = 0.0
            number2 = 0.0
        }
        dismissKeyBoard()

    }
}

extension AddExpenseTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextView.textColor == UIColor.lightGray {
            noteTextView.text = nil
            noteTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextView.text.isEmpty {
            noteTextView.text = "備忘錄"
            // 判斷目前語言是否為英文
            if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
                noteTextView.text = "Note"
            }
            noteTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.addExpenseTableViewController(self, didEdit: updatedata())
    }

}

extension AddExpenseTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accountTextfield.becomeFirstResponder()
        return true
    }
    
    // 輸入金額時，將資料同步到 homedata
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.addExpenseTableViewController(self, didEdit: updatedata())
    }
}

extension AddExpenseTableViewController: MyButtonDelegate {
    
    // 執行 Menu 關閉時的動作
    func myButtonWillEndContextMenuInteraction() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
        // 資料即時同步
        delegate?.addExpenseTableViewController(self, didEdit: updatedata())
    }
    
}
