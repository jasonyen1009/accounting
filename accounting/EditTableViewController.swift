//
//  EditTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/7/1.
//

import UIKit

protocol EditTableViewControllerDelegate {
    func editTableViewController(_ controller: EditTableViewController, didEdit data: Expense)
}

class EditTableViewController: UITableViewController {
    
    var Expensedata: Expense?
    var Incomedata: Income?
    var number1 = 0.0
    var number2 = 0.0
    var calculatetype = ""
    var Expensedelegate: EditTableViewControllerDelegate?
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var BankorPayButton: UIButton!
    @IBOutlet weak var ExorInnameTextfield: UITextField!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TextViewDelegate
        noteTextView.delegate = self
        
        updateUI()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
//    init?(coder: NSCoder, mydata: Expense) {
//        self.mydate = mydata
//        super.init(coder: coder)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // 畫面更新
    func updateUI() {
        
        if let data = Expensedata {
            DatePicker.date = data.date
            ExorInnameTextfield.text = data.expensename
            accountTextfield.text = "\(data.expense)"
            BankorPayButton.setTitle("\(data.paytype)", for: .normal)
            categoryButton.setTitle("\(data.expensetype)", for: .normal)
            noteTextView.text = "\(data.note)"
            
        }
        
        if let data = Incomedata {
            DatePicker.date = data.date
            ExorInnameTextfield.text = data.incomename
            accountTextfield.text = "\(data.income)"
            BankorPayButton.setTitle("\(data.accounts)", for: .normal)
            categoryButton.setTitle("\(data.incometype)", for: .normal)
            noteTextView.text = "\(data.note)"

        }
        
    }
    
    
    func updatedataEx() -> Expense {
        let editdata = Expense(date: DatePicker.date, expensetype: Expensedata?.expensetype ?? "", expensename: ExorInnameTextfield.text ?? "", paytype: Expensedata?.paytype ?? "", expense: Int(accountTextfield.text ?? "0") ?? 0, note: noteTextView.text)
        return editdata
    }
    

    // 即時編輯 資料 , 並回傳
    @IBAction func editdata(_ sender: Any) {
        
        Expensedelegate?.editTableViewController(self, didEdit: updatedataEx())
        
    }
    
    @IBAction func editdate(_ sender: Any) {
        
//        Expensedelegate?.editTableViewController(self, didEdit: updatedataEx())
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//

//    }
    

}

extension EditTableViewController: UITextViewDelegate {
    
    // 由於textview 無法拉 action
    // 改為使用 UITextViewDelegate 中的 func 來達到資料更新
    func textViewDidChange(_ textView: UITextView) {
        
        Expensedelegate?.editTableViewController(self, didEdit: updatedataEx())
        
    }
}
