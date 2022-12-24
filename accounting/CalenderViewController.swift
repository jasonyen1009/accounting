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
        let selectDay = "\(CalendarHelper().yearandmonth(date: now))/\(sender.titleLabel?.text! ?? "")"
        
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
    
    
    
    
}
