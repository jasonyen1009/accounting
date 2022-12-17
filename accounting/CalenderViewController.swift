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
    
    
    // Time
    var time = Timer()
    
    // 取得目前的時間
    var now = Date()
    let dateformatter = DateFormatter()
    
    // calender
    var totalSquares = [String]()
    var allButton = [UIButton]()
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            print("\(CalendarHelper().yearandmonth(date: now)) \(sender.titleLabel?.text! ?? "")")
        }
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
//        monthLabel.text = CalendarHelper().monthString(date: now)
//            + " " + CalendarHelper().yearString(date: now)
        collectionView.reloadData()
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        now = CalendarHelper().plusMonth(date: now)
        setMonthView()
        closealltoggle(allButton)
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
        now = CalendarHelper().minusMonth(date: now)
        setMonthView()
        closealltoggle(allButton)
    }
    
}


extension CalenderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalenderCell
        
        cell.dayOfMonth.setTitle(totalSquares[indexPath.item], for: .normal)
        cell.dayOfMonth.addTarget(self, action: #selector(printdate(sender: )), for: .touchUpInside)
        allButton.append(cell.dayOfMonth)

        
        return cell
    }
    
    
}
