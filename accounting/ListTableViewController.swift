//
//  ListTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/5/23.
//

import UIKit

protocol ListTableViewControllerDelegate {
    func listTableViewController(_ controller: ListTableViewController, didEdit data: [String:[Expense]])
}

class ListTableViewController: UITableViewController {
    
    // 控制顯示資料，支出或是收入
    var selectindex = 0
    
    // 原資料
    // 支出
    // 收入
    var expenselist = [Expense]()
    var incomelist = [Income]()

    // 指定的日期
    let assigneddate: Date?
    
    // display 資料（本頁顯示資料）
    var expensedic = [String:[Expense]]()
    var expensekeys = [String]()
    
    var incomedic = [String:[Income]]()
    var incomekeys = [String]()
    
    
    // 回傳的資料
    var expenserenewaldata: [String:[Expense]]?
    var incomerenewaldata: [String:[Income]]?

    
    // date
    var now = Date()
    let formatter = DateFormatter()
    
    // 用來保存點選的 indexPath
    var selectIndexPath: IndexPath?
    
    // delegate
    var delegate: ListTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // date 格式
        // 進行日期分類的格式
        formatter.dateFormat = "yyyy/MM/dd"
        
        // display 資料 設定
        // expense
        expensedic = Dictionary(grouping: expenselist, by: { formatter.string(from: $0.date)})
        expensekeys = Array(expensedic.keys)
        expensekeys.sort(by: <)
        
        // display 資料 設定
        // income
        incomedic = Dictionary(grouping: incomelist, by: { formatter.string(from: $0.date)})
        incomekeys = Array(incomedic.keys)
        incomekeys.sort(by: <)
        
        // 取得消費類別
        // enpense
        let ttt = Dictionary(grouping: expenselist, by: {$0.expensetype})
        // 決定消費類別 ["spendingtype":[Spending]]
        if let str = ttt.keys.first {
            expenserenewaldata = [str: []]
        }
        
        // 取得消費類別
        // income
        let tt = Dictionary(grouping: incomelist, by: {$0.incometype})
        // 決定消費類別 ["spendingtype":[Spending]]
        if let str = tt.keys.first {
            incomerenewaldata = [str: []]
        }
        
        // 資料分類後，決定要顯示的月份格式判斷
        formatter.dateFormat = "yyyy/MM"
        
        
    }
    
    // expense
    init?(coder: NSCoder, list: [Expense], date: Date, index: Int){
        self.expenselist = list
        self.assigneddate = date
        self.selectindex = index
        super.init(coder: coder)
    }
    //income
    init?(coder: NSCoder, list: [Income], date: Date, index: Int){
        self.incomelist = list
        self.assigneddate = date
        self.selectindex = index
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 數字轉為金錢格式文字
    func moneyString(_ money: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        return formatter.string(from: NSNumber(value: money)) ?? ""
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        switch selectindex {
        case 0:
            // expense
            return expensedic.keys.count
        default :
            // income
            return incomedic.keys.count
        }
//        return expensedic.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // // 判斷 是否為指定的日期，若不是將回傳 0
//        if expensekeys[section].contains(formatter.string(from: assigneddate!)) {
//            return expensedic[expensekeys[section]]!.count
//        }
//        return 0
        
        // 判斷 是否為指定的日期，若不是將回傳 0
        switch selectindex {
        case 0 :
            // expense
            if expensekeys[section].contains(formatter.string(from: assigneddate!)) {
                return expensedic[expensekeys[section]]!.count
            }
            return 0
        default :
            // income
            if incomekeys[section].contains(formatter.string(from: assigneddate!)) {
                return incomedic[incomekeys[section]]!.count
            }
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "data", for: indexPath) as! ExpenseListTableViewCell
        let row = indexPath.row
        let section = indexPath.section
        
        // 自定義 cell
        switch selectindex {
        case 0:
            // expense
            cell.expensenameLabel.text = expensedic[expensekeys[section]]![row].expensename
            cell.expenseLabel.text = moneyString(expensedic[expensekeys[section]]![row].expense)
        default :
            // income
            cell.expensenameLabel.text = incomedic[incomekeys[section]]![row].incomename
            cell.expenseLabel.text = moneyString(incomedic[incomekeys[section]]![row].income)
        }
        
        
       // 判斷 花費的方式
        switch selectindex {
        case 0:
            // expense
            switch expensedic[expensekeys[section]]![row].paytype {
            case "帳戶" :
                cell.accountimageview.image = UIImage(named: "bank")
            case "信用卡" :
                cell.accountimageview.image = UIImage(named: "credit-card")
            default:
                cell.accountimageview.image = UIImage(named: "money")
            }
        default :
            // income
            switch incomedic[incomekeys[section]]![row].incometype {
            case "薪水" :
                cell.accountimageview.image = UIImage(named: "salary")
            case "利息" :
                cell.accountimageview.image = UIImage(named: "interest")
            case "投資" :
                cell.accountimageview.image = UIImage(named: "invest")
            case "收租" :
                cell.accountimageview.image = UIImage(named: "rent")
            case "買賣" :
                cell.accountimageview.image = UIImage(named: "transaction")
            default:
                cell.accountimageview.image = UIImage(named: "game")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 判斷 日期內是否還有資料，若沒有資料將回傳 nil, error
        switch selectindex {
        case 0:
            // expense
            if expensedic[expensekeys[section]]!.isEmpty {
                return nil
            }
            
            // 判斷 是否為指定的日期，若不是將回傳 nil
            if expensekeys[section].contains(formatter.string(from: assigneddate!)) {
                return expensekeys[section]
            }else {
                return nil
            }
        default :
            // income
            if incomedic[incomekeys[section]]!.isEmpty {
                return nil
            }
            
            // 判斷 是否為指定的日期，若不是將回傳 nil
            if incomekeys[section].contains(formatter.string(from: assigneddate!)) {
                return incomekeys[section]
            }else {
                return nil
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch selectindex {
        case 0:
            // expense
            expensedic[expensekeys[indexPath.section]]!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default :
            // income
            incomedic[incomekeys[indexPath.section]]!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    // 刪除表格，產生警告視窗
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("Update action ...")
                success(true)

                 let alertView = UIAlertController(title: "", message: "Are you sure you want to delete the item ? ", preferredStyle: .alert)
                 let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                     self.expensedic[self.expensekeys[indexPath.section]]!.remove(at: indexPath.row)
                     self.tableView.deleteRows(at: [indexPath], with: .fade)
                     // 資料即時同步
                     self.updatedata()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler: { (alert) in
                     print("Cancel")
                })
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                self.present(alertView, animated: true, completion: nil)

            })
            modifyAction.image = UIImage(named: "delete")
            modifyAction.backgroundColor = .purple
            return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
    func updatedata() {
        var data = [Expense]()
        // 資料整理
        for key in expensekeys {
            for i in expensedic[key]! {
                data.append(i)
            }
        }

        // 再次改變資料型別 ["spendingtype": [Spending]]
//        renewaldata = Dictionary(grouping: data, by: { $0.spendingtype})
        let newdata = Dictionary(grouping: expenselist, by: {$0.expensetype})

        expenserenewaldata?[newdata.keys.first!] = data

        delegate?.listTableViewController(self, didEdit: expenserenewaldata ?? [:])
            
    }

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        // 成為 EditTableViewControllerDelegate delegate
        if let controller = segue.destination as? EditTableViewController {
            controller.delegate = self
        }
        
    }
    
    @IBSegueAction func SendData(_ coder: NSCoder) -> EditTableViewController? {
        
        
        
        if let row = tableView.indexPathForSelectedRow?.row,
           let section = tableView.indexPathForSelectedRow?.section {
            
//            print(tableView.indexPathForSelectedRow!)
            
            // 將點選到的 indexPath 保存下來
            selectIndexPath = tableView.indexPathForSelectedRow
            return EditTableViewController(coder: coder, mydata: expensedic[expensekeys[section]]![row])
        }else {
            return nil
        }
    }
    
}

extension ListTableViewController: EditTableViewControllerDelegate {
    
    func editTableViewController(_ controller: EditTableViewController, didEdit data: Expense) {
        
        if let indexpath = selectIndexPath {
            print("data \(data)")
            expensedic[expensekeys[indexpath.section]]![indexpath.row] = data
        }
        
        // 資料重新整理
        var redata = [Expense]()
        for key in expensekeys {
            for i in expensedic[key]! {
                redata.append(i)
            }
        }
        
        // 修改的資料取代原資料
        expenselist = redata
        
        // date 格式
        // 進行日期分類的格式
        formatter.dateFormat = "yyyy/MM/dd"
        
        // display 資料 設定
        expensedic = Dictionary(grouping: expenselist, by: { formatter.string(from: $0.date)})
        expensekeys = Array(expensedic.keys)
        expensekeys.sort(by: <)
        
        // 資料分類後，決定要顯示的月份格式判斷
        formatter.dateFormat = "yyyy/MM"
        
        // 頁面刷新
        tableView.reloadData()
        
        // 即時與 ViewController 中的 totaldata 同步資料
        updatedata()
    }
    
    
}
