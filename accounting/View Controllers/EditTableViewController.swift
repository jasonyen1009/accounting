//
//  EditTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/7/1.
//

import UIKit

protocol ExEditTableViewControllerDelegate {
    func editTableViewController(_ controller: EditTableViewController, didEdit data: Expense)
}

protocol InEditTableViewControllerDelegate {
    func ineditTableViewController(_ controller: EditTableViewController, didEdit data: Income)
}

class EditTableViewController: UITableViewController {
    
    var Expensedata: Expense?
    var Incomedata: Income?
    var number1 = 0.0
    var number2 = 0.0
    var calculatetype = ""
    var Expensedelegate: ExEditTableViewControllerDelegate?
    var Incomedelegate: InEditTableViewControllerDelegate?
    
    var date = Date()
    var dateformatter = DateFormatter()
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var BankorPayButton: UIButton!
    @IBOutlet weak var ExorInnameTextfield: UITextField!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var WeekLabel: UILabel!
    @IBOutlet weak var MonthandDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 將 date 設定為資料的日期
        if let Exdate = Expensedata?.date {
            date = Exdate
        }
        if let Indate = Incomedata?.date {
            date = Indate
        }
        // 抓取 星期
        dateformatter.dateFormat = "EEEE"
        WeekLabel.text = dateformatter.string(from: date)
        // 抓取 幾月 幾號
        dateformatter.dateFormat = "MMMM dd"
        MonthandDateLabel.text = dateformatter.string(from: date)
        
        
        // TextViewDelegate
        noteTextView.delegate = self
        
        updateUI()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // 畫面完全消失才傳送資料回上一頁
    override func viewDidDisappear(_ animated: Bool) {
        Expensedelegate?.editTableViewController(self, didEdit: updatedataEx())
        Incomedelegate?.ineditTableViewController(self, didEdit: updatedataIn())
    }
    
    
    // 畫面更新
    func updateUI() {
        
        if let data = Expensedata {
            ExorInnameTextfield.text = NSLocalizedString("\(data.expensename)", comment: "")
            accountTextfield.text = "\(data.expense)"
            BankorPayButton.setTitle(NSLocalizedString("\(data.paytype)", comment: ""), for: .normal)
            categoryButton.setTitle(NSLocalizedString("\(data.expensetype)", comment: ""), for: .normal)
            noteTextView.text = "\(data.note)"
            
        }
        
        if let data = Incomedata {
            ExorInnameTextfield.text = NSLocalizedString("\(data.incomename)", comment: "")
            accountTextfield.text = "\(data.income)"
            BankorPayButton.setTitle(NSLocalizedString("\(data.accounts)", comment: ""), for: .normal)
            categoryButton.setTitle(NSLocalizedString("\(data.incometype)", comment: ""), for: .normal)
            noteTextView.text = "\(data.note)"

        }
        
    }
    
    
    func updatedataEx() -> Expense {
        let editdata = Expense(date: date, expensetype: Expensedata?.expensetype ?? "", expensename: ExorInnameTextfield.text ?? "", paytype: Expensedata?.paytype ?? "", expense: Int(accountTextfield.text ?? "0") ?? 0, note: noteTextView.text)
        return editdata
    }
    
    func updatedataIn() -> Income {
        let editdata = Income(date: date, incometype: Incomedata?.incometype ?? "", incomename: ExorInnameTextfield.text ?? "", accounts: Incomedata?.accounts ?? "", income: Int(accountTextfield.text ?? "0") ?? 0, note: noteTextView.text)
        return editdata
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
    
}
