//
//  NewTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/5/6.
//

import UIKit

class NewTableViewController: UITableViewController {
    
    var mydata: Spending?
    var number1 = 0.0
    var number2 = 0.0
    var calculatetype = ""
    
    // date
    var now = Date()
    let formatter = DateFormatter()
    

    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var accountnameTextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 禁止下拉
        self.isModalInPresentation = true
        
        // textfield delegate
        accountnameTextfield.delegate = self
        
        // textview delegate
        noteTextView.delegate = self
        
        noteTextView.text = "備忘錄"
        noteTextView.textColor = UIColor.lightGray
        
        // custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: (view.frame.height) * 2 / 6))
        keyboardView.delegate = self
        
        //
        accountTextfield.inputView = keyboardView

        // tableview 收鍵盤
        // 如果使用以下程式碼
        // 會造成 DatePickerview 衝突
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
//        self.view.addGestureRecognizer(tap)
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // 製作 消費類別 Menu
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.changesSelectionAsPrimaryAction = true
        
        categoryButton.menu = UIMenu(children: [
            UIAction(title: "個人", handler: { action in
            }),
            UIAction(title: "飲食", handler: { action in
            }),
            UIAction(title: "購物", handler: { action in
            }),
            UIAction(title: "交通", handler: { action in
            }),
            UIAction(title: "醫療", handler: { action in
            }),
            UIAction(title: "生活", handler: { action in
            })
        
        
        ])
        
        // 製作 消費方式 Menu
        accountButton.showsMenuAsPrimaryAction = true
        accountButton.changesSelectionAsPrimaryAction = true
        accountButton.menu = UIMenu(children: [
            UIAction(title: "帳戶", handler: { action in
            }),
            UIAction(title: "信用卡", handler: { action in
            }),
            UIAction(title: "現金", handler: { action in
            })
        
        ])
                
        
        
    }
    
    //收鍵盤
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    // 將 tableView 的 HeaderInSection 高度設為 0
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        0
//    }
    
    // 將 tableView 的 FooterInSection 高度設為 0
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        0
    }

    
    
    @IBAction func testttbutton(_ sender: Any) {
        print(noteTextView.text ?? "")
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 2
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // 資料
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let date = DatePicker.date
        let sptype = categoryButton.titleLabel?.text ?? ""
        let spname = accountnameTextfield.text ?? ""
        let pytype = accountButton.titleLabel?.text ?? ""
        let spending = Int(accountTextfield.text!) ?? 0
        let note = noteTextView.text ?? ""
        
        mydata = Spending(date: date, spendingtype: sptype, spendingname: spname, paytype: pytype, spending: spending, note: note)
        
        
    }
    
    

}
extension NewTableViewController: KeyboardDelegate {
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

extension NewTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextView.textColor == UIColor.lightGray {
            noteTextView.text = nil
            noteTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextView.text.isEmpty {
            noteTextView.text = "備忘錄"
            noteTextView.textColor = UIColor.lightGray
        }
    }
    
}


extension NewTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accountTextfield.becomeFirstResponder()
            return true
      }
}
