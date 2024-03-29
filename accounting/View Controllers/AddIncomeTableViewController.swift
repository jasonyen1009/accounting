//
//  AddIncomeTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/8/10.
//

import UIKit

protocol AddIncomeTableViewControllerDelegate {
    func addIncomeTableViewController(_ controller: AddIncomeTableViewController, didEdit data: Income)
}

class AddIncomeTableViewController: UITableViewController {
    
    var mydata: Income?
    var number1 = 0.0
    var number2 = 0.0
    var calculatetype = ""
    
    // date
    var now = Date()
    let formatter = DateFormatter()
    var minutes = ""
    
    // category
    var category = "薪水"
    
    var delegate: AddIncomeTableViewControllerDelegate?

    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var accountImagview: UIImageView!
    @IBOutlet weak var incomenameTextfield: UITextField!
    @IBOutlet weak var incomeTextfield: UITextField!
    @IBOutlet weak var noteTextview: UITextView!
    @IBOutlet weak var selectbank: UILabel!
    
    @IBOutlet weak var categoryButton: MyButton!
    
    // 用於模糊化的 UIVisualEffectView
    var blurEffectView: UIVisualEffectView?
    
    // 使用 userDefault 抓取 最愛的銀行資料
    let userDefault = UserDefaults.standard
    // 顯示預設的最愛銀行
    var favoritebanks = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textfield delegate
        incomeTextfield.delegate = self
        incomenameTextfield.delegate = self
        
        // textview delegate
        noteTextview.delegate = self
        
        // categoryButton delegate
        categoryButton.delegate = self

        
        noteTextview.text = "備忘錄"
        // 判斷目前語言是否為英文
        if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
            noteTextview.text = "Note"
        }
        noteTextview.textColor = UIColor.lightGray

        // custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: (view.frame.height) * 2 / 6))
        keyboardView.delegate = self
        
        //
        incomeTextfield.inputView = keyboardView
        
        // 抓取目前的時間
        formatter.dateFormat = "HH:mm:ss.SSS"
        let minandsec = formatter.string(from: now)
        minutes = minandsec
        
        // 抓取最愛的銀行名稱
        let first = userDefault.array(forKey: "Banks") as? [String]
        // 給定預設最愛的銀行，否則到新裝置會閃退
        favoritebanks = first?[0] ?? NSLocalizedString("玉山銀行", comment: "")
        selectbank.text = first?[0] ?? NSLocalizedString("玉山銀行", comment: "")
        // 接收通知 bank 更新通知
        NotificationCenter.default.addObserver(self, selector: #selector(updatebank(noti: )), name: AllNotification.bankmessage, object: nil)
        
        // 設定 button 的 menu 表單
        setButton(categoryButton)
        
        
    }
    
    // notification 
    @objc func updatebank(noti: Notification) {
        if let userInfo = noti.userInfo,
           let bank = userInfo[AllNotification.bankinfo] as? String {
            favoritebanks = bank
            selectbank.text = bank
        }
        
        // 資料即時同步
        delegate?.addIncomeTableViewController(self, didEdit: updatedata())
    }
    
    //收鍵盤
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func changeday(_ sender: UIDatePicker) {
        // 資料即時同步
        delegate?.addIncomeTableViewController(self, didEdit: updatedata())
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
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
    
    func updatedata() -> Income {
        formatter.dateFormat = "yyyy/MM/dd"
        let connectdate = "\(formatter.string(from: DatePicker.date)) \(minutes)"
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        
        let inctype = category
        let incname = incomenameTextfield.text ?? ""
        let account = favoritebanks
        let income = Int(incomeTextfield.text!) ?? 0
        let note = noteTextview.text ?? ""
        
        mydata = Income(date: formatter.date(from: connectdate)!, incometype: inctype, incomename: incname, accounts: account, income: income, note: note)
        
        return mydata!
    }
    
    func setButton(_ button: UIButton) {
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        
        // 判斷是否為 英文
        if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
            button.menu = UIMenu(children: [
                UIAction(title: "salary",  handler: { [self] action in
                    category = "薪水"
                    accountImagview.image = UIImage(named: "salary")
                }),
                UIAction(title: "interest",  handler: { [self] action in
                    category = "利息"
                    accountImagview.image = UIImage(named: "interest")
                }),
                UIAction(title: "invest",  handler: { [self] action in
                    category = "投資"
                    accountImagview.image = UIImage(named: "invest")
                }),
                UIAction(title: "rent",  handler: { [self] action in
                    category = "收租"
                    accountImagview.image = UIImage(named: "rent")
                }),
                UIAction(title: "transaction",  handler: { [self] action in
                    category = "買賣"
                    accountImagview.image = UIImage(named: "transaction")
                }),
                UIAction(title: "play",  handler: { [self] action in
                    category = "娛樂"
                    accountImagview.image = UIImage(named: "game")
                })
                
            ])
        }else {
            button.menu = UIMenu(children: [
                UIAction(title: "薪水",  handler: { [self] action in
                    category = "薪水"
                    accountImagview.image = UIImage(named: "salary")
                }),
                UIAction(title: "利息",  handler: { [self] action in
                    category = "利息"
                    accountImagview.image = UIImage(named: "interest")
                }),
                UIAction(title: "投資",  handler: { [self] action in
                    category = "投資"
                    accountImagview.image = UIImage(named: "invest")
                }),
                UIAction(title: "收租",  handler: { [self] action in
                    category = "收租"
                    accountImagview.image = UIImage(named: "rent")
                }),
                UIAction(title: "買賣",  handler: { [self] action in
                    category = "買賣"
                    accountImagview.image = UIImage(named: "transaction")
                }),
                UIAction(title: "娛樂",  handler: { [self] action in
                    category = "娛樂"
                    accountImagview.image = UIImage(named: "game")
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

}

extension AddIncomeTableViewController: KeyboardDelegate {
    
    func keyWasTapped(character: String) {
        incomeTextfield.insertText(character)
    }
    
    func deletTapped() {
        incomeTextfield.deleteBackward()
        
    }
    
    func deletAllTapped() {
        incomeTextfield.text?.removeAll()
        
    }
    
    func plusTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "+"
    }
    
    func multiplicationTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "X"
    }
    
    func deductTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "-"
    }
    
    func divisionTapped() {
        if let number = incomeTextfield.text {
            number1 = Double(number) ?? 0
            incomeTextfield.text?.removeAll()
        }
        calculatetype = "/"
    }
    
    func calculateTapped() {
        if let number = incomeTextfield.text {
            number2 = Double(number) ?? 0
            switch calculatetype{
            case "+":
                incomeTextfield.text = String(number1 + number2)
            case "X":
                incomeTextfield.text = String(number1 *  number2)
            case "-":
                incomeTextfield.text = String(number1 -  number2)
            case "/":
                incomeTextfield.text = String(number1 /  number2)
            default :
                print("")
            }
            number1 = 0.0
            number2 = 0.0
        }
        dismissKeyBoard()
        
    }
}



extension AddIncomeTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextview.textColor == UIColor.lightGray {
            noteTextview.text = nil
            noteTextview.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextview.text.isEmpty {
            noteTextview.text = "備忘錄"
            // 判斷目前語言是否為英文
            if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
                noteTextview.text = "Note"
            }
            noteTextview.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.addIncomeTableViewController(self, didEdit: updatedata())
    }
    
}


extension AddIncomeTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        incomeTextfield.becomeFirstResponder()
        return true
    }
    
    // 輸入金額時，將資料同步到 homedata
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.addIncomeTableViewController(self, didEdit: updatedata())
    }
}

extension AddIncomeTableViewController: MyButtonDelegate {
    func myButtonWillEndContextMenuInteraction() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
        delegate?.addIncomeTableViewController(self, didEdit: updatedata())
    }
}
