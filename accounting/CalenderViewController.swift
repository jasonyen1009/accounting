//
//  CalenderViewController.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2022/12/11.
//

import UIKit

class CalenderViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var listTableView: UITableView!
    
    
    // Time
    var time = Timer()
    
    // 取得目前的時間
    var now = Date()
    let dateformatter = DateFormatter()
    
    // 選取的日期
    var assigneddate: Date?

    // calender
    var totalSquares = [String]()
    var allButton = [UIButton]()
    
    // 支出, 收入 種類
    var expenseLabel = ["個人", "飲食", "購物", "交通", "醫療", "生活"]
    var incomeLabel = ["薪水", "利息", "投資", "收租", "買賣", "娛樂"]
    
    // 所有支出總計
    var expensetotaldata = [
        "個人": [Expense](),
        "飲食": [Expense](),
        "購物": [Expense](),
        "交通": [Expense](),
        "醫療": [Expense](),
        "生活": [Expense]()
    ]
    
    // 所有收入總計
    var incometotaldata = [
        "薪水": [Income](),
        "利息": [Income](),
        "投資": [Income](),
        "收租": [Income](),
        "買賣": [Income](),
        "娛樂": [Income]()
    ]
    
    var displaydata = [Any]()
    
    // 用來保存點選的 indexPath
    var selectIndexPath: IndexPath?
    
    var expense: Expense?
    var income: Income?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview delegate
        listTableView.delegate = self
        listTableView.dataSource = self
        
        // 取得儲存 expense 的資料
        if let expense = Expense.loadExpense() {
            self.expensetotaldata = expense
        }
        
        // 取得儲存 income 的資料
        if let income = Income.loadIncome() {
            self.incometotaldata = income
        }
        
        setCellsView()
        setMonthView()
        
        // 顯示今日的資料
        dateformatter.dateFormat = "yyyy/MM/dd"
        
        // 測試將支出與收入資料放在一起
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        
        
        // 接收來自 ViewController 更新 Expense, Income 通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateExorIn(noti: )), name: AllNotification.updateEXorINFromViewControlller, object: nil)
        

    }
    
    
    // 再次讀取最新的 Expensetotaldata, Incometotaldata
    @objc func updateExorIn(noti: Notification) {
        // 取得儲存 expense 的資料
        if let expense = Expense.loadExpense() {
            self.expensetotaldata = expense
        }
        
        // 取得儲存 income 的資料
        if let income = Income.loadIncome() {
            self.incometotaldata = income
        }
        
        // 先刪除所有顯示的資料
        displaydata.removeAll()
        // 測試將支出與收入資料放在一起
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        
        listTableView.reloadData()
        
    }
    
    
    override open var shouldAutorotate: Bool {
        return false
        
    }
    
    
    func closealltoggle(_ button: [UIButton]) {
        for i in button {
            i.isSelected = false
        }
    }
    
    @objc func printdate(sender: UIButton) {
        closealltoggle(allButton)
        // 判斷是否為空的 Button
        if sender.titleLabel?.text == "Button" {
            sender.isSelected = false
            sender.isEnabled = false
        }else {
            sender.isSelected.toggle()
            
            // 取得點選日期
            print("\(CalendarHelper().yearandmonth(date: now))/\(sender.titleLabel?.text! ?? "")")
        }
        
        // 取得點選日期
        var selectDay = "\(CalendarHelper().yearandmonth(date: now))/\(sender.titleLabel?.text! ?? "")"
        
        // 判斷日期數字是否小於 10，若小於 10 必須補 0
        if Int(sender.titleLabel?.text ?? "") ?? 0 < 10 {
            selectDay = "\(CalendarHelper().yearandmonth(date: now))/0\(sender.titleLabel?.text! ?? "")"
        }
        
        // 先刪除所有顯示的資料
        displaydata.removeAll()
        // 測試將支出與收入資料放在一起
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == selectDay {
                    displaydata.append(k)
                }
            }
        }
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == selectDay {
                    displaydata.append(k)
                }
            }
        }
        listTableView.reloadData()
        // 將 now 日期改為 所選的日期
        now = dateformatter.date(from: selectDay)!
        
    }
    
    
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 10

        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonthView() {
        totalSquares.removeAll()

        let daysInMonth = CalendarHelper().daysInMonth(date: now)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: now)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)

        var count: Int = 1

        while(count <= 42)
        {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth)
            {
                totalSquares.append("")
            }
            else
            {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        
        let text = CalendarHelper().monthString(date: now)
        + " " + CalendarHelper().yearString(date: now)
                
        monthButton.setTitle(text, for: .normal)
    }
    
    // 數字轉為金錢格式文字
    func moneyString(_ money: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        return formatter.string(from: NSNumber(value: money)) ?? ""
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        now = CalendarHelper().plusMonth(date: now)
        setMonthView()
        closealltoggle(allButton)
        collectionView.reloadData()
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
        now = CalendarHelper().minusMonth(date: now)
        setMonthView()
        closealltoggle(allButton)
        collectionView.reloadData()
    }
    
    // 顯示一半頁面 Controller 的 Sheet
    @IBSegueAction func ShowSheet(_ coder: NSCoder) -> EditTableViewController? {
        let controller = EditTableViewController(coder: coder)
        if let sheetPresentationController = controller?.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
        }
        return controller
    }
    
    // 傳送資料到下一頁
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EditTableViewController ,
           let row = listTableView.indexPathForSelectedRow?.row {
            
            // 保存所選的 indexpath
            selectIndexPath = listTableView.indexPathForSelectedRow
            
            
            var index = 0
            // 先判斷 選到的資料為 Expense or Income
            if type(of: displaydata[row]) == Expense.self {
                // Expensedelegate 成為代理人
                controller.Expensedelegate = self
                
                let dd = displaydata[row] as! Expense
                controller.Expensedata = dd
                
                // 刪除 傳送的資料
                // expense 使用較為安全的寫法
                // income 使用簡化後的寫法
                for i in expenseLabel {
                    index = 0
                    for k in expensetotaldata["\(i)"] ?? [] {
                        // 判斷是否為 點選的資料
                        // 利用更加精準的時間來做判斷
                        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                        if dateformatter.string(from: dd.date) == dateformatter.string(from: k.date) {
                            print("dd")
//                            print("k", k)
                            print(index)
                            // 刪除選中的資料
                            expensetotaldata["\(i)"]?.remove(at: index)
                        }
                        index += 1
                        // 判斷後需要將時間格式改回
                        // 否則 216 row 中的 now = dateformatter.date(from: selectDay)! 會閃退
                        dateformatter.dateFormat = "yyyy/MM/dd"
                    }
                }
            } else {
                // Incomedelegate 成為代理人
                controller.Incomedelegate = self
                let dd = displaydata[row] as! Income
                controller.Incomedata = dd
                // 刪除 傳送的資料
                for i in incomeLabel {
                    for (ind, k) in incometotaldata["\(i)"]!.enumerated() {
                        // 判斷是否為 點選的資料
                        // 利用更加精準的時間來做判斷
                        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                        if dateformatter.string(from: dd.date) == dateformatter.string(from: k.date) {
                            // 刪除選中的資料
                            incometotaldata["\(i)"]?.remove(at: ind)
                        }
                        // 判斷後需要將時間格式改回
                        // 否則 216 row 中的 now = dateformatter.date(from: selectDay)! 會閃退
                        dateformatter.dateFormat = "yyyy/MM/dd"
                    }
                }
                
            }
            
        }
    }
}


extension CalenderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalenderCell
        
        cell.dayOfMonth.setTitle(totalSquares[indexPath.item], for: .normal)
        
        // 判斷 button 上面的字是否為空白
        // 若為空白就無法點選
        if totalSquares[indexPath.item] == "" {
            cell.dayOfMonth.isEnabled = false
        }else {
            cell.dayOfMonth.isEnabled = true
        }
        // 判斷是否為今日日期
        // 若為今日日期 button 為選取模式
        dateformatter.dateFormat = "dd"
        // 若小於 10 必須補 0
        if Int(totalSquares[indexPath.item]) ?? 0 < 10 {
            if "0\(totalSquares[indexPath.item])" == dateformatter.string(from: now) {
                cell.dayOfMonth.isSelected = true
            }
        }
        if totalSquares[indexPath.item] == dateformatter.string(from: now) {
            cell.dayOfMonth.isSelected = true
        }
        dateformatter.dateFormat = "yyyy/MM/dd"
        
        cell.dayOfMonth.addTarget(self, action: #selector(printdate(sender: )), for: .touchUpInside)
        allButton.append(cell.dayOfMonth)
        
        return cell
    }
    
    
}

extension CalenderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displaydata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calcelltable", for: indexPath) as! CalenderTableViewCell 
        
        // 給定支出顯示資料
        // 判斷每筆 displaydata 為 Expense 還是 Income
        if type(of: displaydata[indexPath.row]) == Expense.self {
            let dd = displaydata[indexPath.row] as! Expense
            
            cell.cellnameLabel.text = "\(dd.expensename)"
            switch dd.paytype {
            case "帳戶" :
                cell.cellImageView.image = UIImage(named: "bank")
            case "信用卡" :
                cell.cellImageView.image = UIImage(named: "credit-card")
            default :
                cell.cellImageView.image = UIImage(named: "money")
            }
            cell.cellmoneyLabel.text = "\(moneyString(dd.expense))"
            cell.cellmoneyLabel.textColor = UIColor(red: 200/255, green: 45/255, blue: 11/255, alpha: 1)

        }else {
            let dd = displaydata[indexPath.row] as! Income
            
            cell.cellnameLabel.text = "\(dd.incomename)"
            switch dd.incometype {
            case "薪水" :
                cell.cellImageView.image = UIImage(named: "salary")
            case "利息" :
                cell.cellImageView.image = UIImage(named: "interest")
            case "投資" :
                cell.cellImageView.image = UIImage(named: "invest")
            case "收租" :
                cell.cellImageView.image = UIImage(named: "rent")
            case "買賣" :
                cell.cellImageView.image = UIImage(named: "transaction")
            default:
                cell.cellImageView.image = UIImage(named: "game")
            }
            cell.cellmoneyLabel.text = "\(moneyString(dd.income))"
            cell.cellmoneyLabel.textColor = UIColor(red: 115/255, green: 186/255, blue: 155/255, alpha: 1)

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    
}

extension CalenderViewController: ExEditTableViewControllerDelegate {
    func editTableViewController(_ controller: EditTableViewController, didEdit data: Expense) {

        expense = data
        // 判斷為哪種消費, 並新增至該消費中
        switch expense?.expensetype {
        case "個人":
            expensetotaldata["個人"]?.insert(expense!, at: 0)
        case "飲食":
            expensetotaldata["飲食"]?.insert(expense!, at: 0)
        case "購物":
            expensetotaldata["購物"]?.insert(expense!, at: 0)
        case "交通":
            expensetotaldata["交通"]?.insert(expense!, at: 0)
        case "醫療":
            expensetotaldata["醫療"]?.insert(expense!, at: 0)
        default:
            expensetotaldata["生活"]?.insert(expense!, at: 0)
        }
        
        print(data)
        
        // 畫面重新整理
        // 先刪除所有顯示的資料
        displaydata.removeAll()
        
        // 測試將支出與收入資料放在一起
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        
        listTableView.reloadData()
        
        // 取得最新的資料後再保存到 expensetotaldata 內
        Expense.SaveExpense(expensetotaldata)
        NotificationCenter.default.post(name: AllNotification.updateEXorINFromCalenderViewController, object: nil)
    }
    
    
}

extension CalenderViewController: InEditTableViewControllerDelegate {
    func ineditTableViewController(_ controller: EditTableViewController, didEdit data: Income) {

        income = data
        switch income?.incometype {
        case "薪水":
            incometotaldata["薪水"]?.insert(income!, at: 0)
        case "利息":
            incometotaldata["利息"]?.insert(income!, at: 0)
        case "投資":
            incometotaldata["投資"]?.insert(income!, at: 0)
        case "收租":
            incometotaldata["收租"]?.insert(income!, at: 0)
        case "買賣":
            incometotaldata["買賣"]?.insert(income!, at: 0)
        default:
            incometotaldata["娛樂"]?.insert(income!, at: 0)
        }
        
        print(data)
        
        // 畫面重新整理
        // 先刪除所有顯示的資料
        displaydata.removeAll()
        
        // 測試將支出與收入資料放在一起
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為今日的資料
                if dateformatter.string(from: k.date) == dateformatter.string(from: now) {
                    displaydata.append(k)
                }
            }
        }
        
        listTableView.reloadData()
        // 取得最新的資料後再保存到 expensetotaldata 內
        Income.SaveIncome(incometotaldata)
        NotificationCenter.default.post(name: AllNotification.updateEXorINFromCalenderViewController, object: nil)
    }
    
}
