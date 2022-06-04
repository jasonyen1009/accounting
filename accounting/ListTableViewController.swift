//
//  ListTableViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/5/23.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // 原資料
    var list = [Spending]()
    
    // 新資料（本頁顯示資料）
    var dic = [String:[Spending]]()
    var keys = [String]()
    
    // 回傳的資料
    var renewaldata :[String:[Spending]]?
    
    // date
    var dateComponents = DateComponents()
    var now = Date()
    let formatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // date 格式
        formatter.dateFormat = "yyyy/MM/dd"
        // 新資料 設定
        dic = Dictionary(grouping: list, by: { formatter.string(from: $0.date)})
        keys = Array(dic.keys)
        keys.sort(by: <)
//        print(dic)
        // 取得消費類別
        let ttt = Dictionary(grouping: list, by: {$0.spendingtype})
        
//        print(ttt.keys.first ?? "")
        
        // 決定消費類別 ["spendingtype":[Spending]]
        if let str = ttt.keys.first {
            renewaldata = [str: []]
        }

//        print(dic)


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    init?(coder: NSCoder, list: [Spending]){
        self.list = list
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
        
        return dic.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
//        let dic = Dictionary(grouping: list, by: { $0.date})
        
//        var keys = Array(dic.keys)
//        keys.sort(by: <)
//        let item = dic[keys[section]]!

        return dic[keys[section]]!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "data", for: indexPath) as! SpendingListTableViewCell
        let row = indexPath.row
        let section = indexPath.section

        // 自定義 cell
        cell.spendingnameLabel.text = dic[keys[section]]![row].spendingname
        cell.spendingLabel.text = moneyString(dic[keys[section]]![row].spending)
        
        // 判斷 花費的方式
        switch dic[keys[section]]![row].paytype {
        case "帳戶" :
            cell.accountimageview.image = UIImage(named: "bank")
        case "信用卡" :
            cell.accountimageview.image = UIImage(named: "credit-card")
        default:
            cell.accountimageview.image = UIImage(named: "money")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        // 判斷 日期內是否還有資料，若沒有資料將回傳 nil
        if dic[keys[section]]!.isEmpty {
            return nil
        }else {
            return keys[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        dic[keys[indexPath.section]]!.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
//        print(renewaldata)

    }
    
    
    // 刪除表格，產生警告視窗
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("Update action ...")
                success(true)

                 let alertView = UIAlertController(title: "", message: "Are you sure you want to delete the item ? ", preferredStyle: .alert)
                 let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                     self.dic[self.keys[indexPath.section]]!.remove(at: indexPath.row)
//                     self.dic.keys[indexPath.section]!.remove(at: indexPath.row)
//                     self.imagesArray.remove(at: indexPath.row)
                     self.tableView.deleteRows(at: [indexPath], with: .fade)
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
        var data = [Spending]()
        // 資料整理
        for key in keys {
            for i in dic[key]! {
                data.append(i)
            }
        }
    
        // 再次改變資料型別 ["spendingtype": [Spending]]
//        renewaldata = Dictionary(grouping: data, by: { $0.spendingtype})
        let ttt = Dictionary(grouping: list, by: {$0.spendingtype})
        
        renewaldata?[ttt.keys.first!] = data
    }
    

}
