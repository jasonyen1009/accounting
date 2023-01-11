//
//  AccountTableViewController.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2022/12/29.
//

import UIKit

class AccountTableViewController: UITableViewController {

    @IBOutlet weak var sortBarButton: UIBarButtonItem!
    
    var favorite = [
        "favorite": [
        ],
        
        "banks": [
            "玉山銀行",
            "台新銀行",
            "富邦銀行",
            "王道銀行",
            "國泰銀行",
            "LINE BANK"
        ]
    ]
    
    var keys = [String]()
    
    let userDefault = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 將 favorite 的 keys 加入到 keys 中
        for i in favorite.keys {
            keys.append(i)
        }
        // 必須加入 sort 不然會亂跳
        keys.sort(by: >)
        
        var first = favorite["banks"]![0]
        favorite["favorite"]?.append(first)
        
        // 判斷是否有保存過資料
        if (userDefault.array(forKey: "Banks") != nil) {
            // 取代之前保存的順序
            favorite["banks"] = userDefault.array(forKey: "Banks") as? [String]
            favorite["favorite"]?.removeAll()
            first = favorite["banks"]![0]
            favorite["favorite"]?.append(first)
        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return favorite.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favorite[keys[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        keys[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
//        content.image = UIImage(systemName: "circle.fill")
        content.text = favorite[keys[indexPath.section]]![indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    
    @IBAction func didtapsort(_ sender: UIBarButtonItem) {
        
        if self.isEditing {
            self.isEditing = false
            sortBarButton.title = "Sort"
        }else {
            self.isEditing = true
            sortBarButton.title = "Done"
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let moveobject = favorite["banks"]?[sourceIndexPath.row]
        favorite["banks"]?.remove(at: sourceIndexPath.row)
        favorite["banks"]?.insert(moveobject!, at: destinationIndexPath.row)

        let first = favorite["banks"]![0]
        favorite["favorite"]?.removeAll()
        favorite["favorite"]?.append(first)
        
        tableView.reloadData()
        
        // 保存初始資料到 userDefault
        userDefault.set(favorite["banks"], forKey: "Banks")
                
    }
    
    // 隱藏 刪除按鈕
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // 隱藏 刪除按鈕的空白位置
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // 點選 Tableview 事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 返回上一頁
        navigationController?.popViewController(animated: true)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
