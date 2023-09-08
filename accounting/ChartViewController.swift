//
//  ChartViewController.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2023/2/17.
//

import UIKit
import Charts

class ChartViewController: UIViewController {


    
    @IBOutlet weak var ExandInLineChartView: LineChartView!
    
    @IBOutlet weak var expenseBarChartView: BarChartView!
    @IBOutlet weak var incomeBarChartView: BarChartView!
    
    @IBOutlet weak var expenseButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    
    @IBOutlet weak var TimeframeSelectorButton: UIButton!
    @IBOutlet weak var changeDateButton: UIButton!
    
    @IBOutlet weak var expenseUILabel: UILabel!
    @IBOutlet weak var incomeUILabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    // Time
    var time = Timer()
    
    // 取得目前的時間
    var now = Date()
    let dateformatter = DateFormatter()
    var dateString = ""
    
    
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
    
    var expense: Expense?
    var income: Income?
    
    // 每日的總額
    var everyDateExpense: [Int] = []
    var everyDateIncome: [Int] = []
    // 每個類別的總額
    var everyExpense: [Int] = []
    var everyIncome: [Int] = []
    
    // 圖表顏色
    let colors = [
        UIColor(red: 67/255, green: 97/255, blue: 238/255, alpha: 1),
        UIColor(red: 63/255, green: 55/255, blue: 201/255, alpha: 1),
        UIColor(red: 58/255, green: 12/255, blue: 163/255, alpha: 1),
        UIColor(red: 114/255, green: 9/255, blue: 183/255, alpha: 1),
        UIColor(red: 181/255, green: 23/255, blue: 158/255, alpha: 1),
        UIColor(red: 247/255, green: 37/255, blue: 133/255, alpha: 1)
    ]
    
    // 控制 LineChart 圖表的顯示類別
    var chartDisplayType = "ex"
    
    // 保存目前選單的文字 Day Week Month
    var TimeframeSelector = "Day"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定 月份與年份
//        monthLabel.text = "\(CalendarHelper().monthString(date: now)) \(CalendarHelper().yearString(date: now))"
        
        // 取得儲存 expense 的資料
        if let expense = Expense.loadExpense() {
            self.expensetotaldata = expense
        }
        
        // 取得儲存 income 的資料
        if let income = Income.loadIncome() {
            self.incometotaldata = income
        }
        
        
        // 設定初始畫面的月份字串 格式
        dateformatter.dateFormat = "yyyy/MM"
        dateString = dateformatter.string(from: now)
        
        // 更新所有 chart
        updateAllChart(dateString: dateString)
        
        // 接收來自 ViewController 更新 Expense, Income 通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateExorIn(noti: )), name: AllNotification.updateEXorINFromViewControlller, object: nil)
        
        setButton(button: expenseButton, .systemRed)
        setButton(button: incomeButton, .systemGray)
        
        setButton(TimeframeSelectorButton)
        
        // 設定月份字串 格式
        dateformatter.dateFormat = "yyyy,MMM"
        changeDateButton.setTitle(dateformatter.string(from: now), for: .normal)
        dateformatter.dateFormat = "yyyy/MM"
        
    }
    
    
    func setButton(_ button: UIButton) {
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        button.menu = UIMenu(children: [
            UIAction(title: "Day",  handler: { [self] action in
                // 設置 button 顯示 Day
                TimeframeSelector = "Day"
                // 設定判斷格式
                dateformatter.dateFormat = "yyyy/MM/dd"
                // 更新所有 chart
                updateAllChart(dateString: dateString)
                
            }),
            UIAction(title: "Week",  handler: { [self] action in
                // 設置 button 顯示 Week
                TimeframeSelector = "Week"
                // 設定判斷格式
                dateformatter.dateFormat = "yyyy/MM/dd"
                // 更新所有 chart
                updateAllChart(dateString: dateString)

            }),
            UIAction(title: "Month",  handler: { [self] action in
                // 設置 button 顯示 Month
                TimeframeSelector = "Month"
                // 設定判斷格式
                dateformatter.dateFormat = "yyyy/MM/dd"
                // 更新所有 chart
                updateAllChart(dateString: dateString)

            }),
        ])
    }
    
    
    // 按鈕的顏色
    func setButton(button: UIButton, _ color: UIColor) {
        let originalImage = UIImage(systemName: "circle.fill")?.withTintColor(color, renderingMode: .alwaysOriginal)

        // 設定縮小後的圖片大小
        let scaledSize = CGSize(width: 10, height: 10) // 設定你想要的大小
        
        // 透過 UIGraphicsImageRenderer 來縮小圖片
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let scaledImage = renderer.image { context in
            originalImage?.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        
        // 設定縮小後的圖片為 Button 的圖片
        button.setImage(scaledImage, for: .normal)
        button.tintColor = color
    }
    
    
    
    // notification
    @objc func updateExorIn(noti: Notification) {
        // 取得儲存 expense 的資料
        if let expense = Expense.loadExpense() {
            self.expensetotaldata = expense
        }
        
        // 取得儲存 income 的資料
        if let income = Income.loadIncome() {
            self.incometotaldata = income
        }
        // 設定初始畫面的月份字串 格式
        dateformatter.dateFormat = "yyyy/MM"
        dateString = dateformatter.string(from: now)
        
        updateAllChart(dateString: dateString)
    }
    
    // 計算 expense 每日的總額
    func dailyExpense(dateString: String) {
        
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        // allEx 會存取每日的總額
        var allEx = 0
        // 抓取每日的日期
        for d in 1..<CalendarHelper().daysInMonth(date: now) + 1 {
            // 抓取所有資料進行比對
            for i in expenseLabel {
                for k in expensetotaldata["\(i)"] ?? [] {
                    // 判斷日期是否小於 10 號，小於就補 0
                    if d < 10 {
                        // 判斷資料若為同一天日期就增加支出
                        if dateformatter.string(from: k.date) == "\(dateString)/0\(d)" {
                            allEx += k.expense
                        }
                    }
                    if dateformatter.string(from: k.date) == "\(dateString)/\(d)" {
                        allEx += k.expense
                    }
                }
            }
            // 將每日的支出總額加入到 everyExpense
            everyDateExpense.append(allEx)
            // 將 allEx 歸 0
            allEx = 0
        }
    }
    
    // 計算 income 每日的總額
    func dailyIncome(dateString: String) {
        
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var allIn = 0
        // 抓取每日的日期
        for d in 1..<CalendarHelper().daysInMonth(date: now) + 1 {
            // 抓取所有資料進行比對
            for i in incomeLabel {
                for k in incometotaldata["\(i)"] ?? [] {
                    // 判斷日期是否小於 10 號，小於就補 0
                    if d < 10 {
                        // 判斷資料若為同一天日期就增加支出
                        if dateformatter.string(from: k.date) == "\(dateString)/0\(d)" {
                            allIn += k.income
                        }
                    }
                    if dateformatter.string(from: k.date) == "\(dateString)/\(d)" {
                        allIn += k.income
                    }
                }
            }
            // 將每日的支出總額加入到 everyExpense
            everyDateIncome.append(allIn)
            // 將 allEx 歸 0
            allIn = 0
        }
    }
    
    // 計算 expense 每個類別的總額
    func categoryExpense(dateString: String) {
        // 每個支出類別的總和
        var typeEx = 0
        // 抓取所有資料進行比對
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                // 轉換為 月份格式
                dateformatter.dateFormat = "yyyy/MM"
                if dateformatter.string(from: k.date) == dateString {
                    typeEx += k.expense
                }
            }
            everyExpense.append(typeEx)
            typeEx = 0
        }
        
        // 將日期格式調整回來
        dateformatter.dateFormat = "yyyy/MM/dd"
    }
    
    // 抓取指定日期 當日的總 支出
    func getTotalExpenseOnSelectedDate(dateString: String) -> Int {
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var selectDayEx = 0
        // 抓取所有資料進行比對
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                if dateformatter.string(from: k.date) == dateString {
                    selectDayEx += k.expense
                }
            }
        }
        
        return selectDayEx
    }
    
    // 抓取指定日期 當日的總 收入
    func getTotalIncomeOnSelectedDate(dateString: String) -> Int {
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var selectDayIn = 0
        // 抓取所有資料進行比對
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                if dateformatter.string(from: k.date) == dateString {
                    selectDayIn += k.income
                }
            }
        }
        
        return selectDayIn
    }
    
    // 抓取指定日期 當月的總 支出 // dateString = "2023/08"
    func getTotalExpenseOnSelectedMonth(dateString: String) -> Int {
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var selectMonthEx = 0
        // 抓取所有資料進行比對
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                if dateformatter.string(from: k.date).contains(dateString) {
                    selectMonthEx += k.expense
                }
            }
        }
        return selectMonthEx
    }
    
    // 抓取指定日期 當月的總 收入 // dateString = "2023/08"
    func getTotalIncomeOnSelectedMonth(dateString: String) -> Int {
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var selectMonthIn = 0
        // 抓取所有資料進行比對
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                if dateformatter.string(from: k.date).contains(dateString) {
                    selectMonthIn += k.income
                }
            }
        }
        return selectMonthIn
    }
    
    // 回傳一週的支出 array -> LineChart
    func 一週支出(day: String) -> [Int] {
        var expense = [Int]()
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        for i in CalendarHelper().getDatesForWeek(date: dateformatter.date(from: day)!) {
            expense.append(getTotalExpenseOnSelectedDate(dateString: i))
        }
        
        return expense
    }
    
    // 回傳一週的收入 array -> LineChart
    func 一週收入(day: String) -> [Int] {
        var income = [Int]()
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        for i in CalendarHelper().getDatesForWeek(date: dateformatter.date(from: day)!) {
            income.append(getTotalIncomeOnSelectedDate(dateString: i))
        }
        return income
    }
    
    // 回傳一年的 支出 array -> LineChart
    func 一年支出(day: String) -> [Int] {
        var expense = [Int]()
        // 建立 ["01", "02", "03", "04"... "12"] 的 Array()
        let months = (1...12).map { String(format: "%02d", $0) }
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM"
        // 將 year 與 month 合併 -> ["year/01", "year/02", ... "year/12"]
        for i in months.map({ month in
            "\(CalendarHelper().yearString(date: now))/\(month)"
        }) {
            expense.append(getTotalExpenseOnSelectedMonth(dateString: i))
        }
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        return expense
    }
    
    // 回傳一年的 收入 array -> LineChart
    func 一年收入(day: String) -> [Int] {
        var income = [Int]()
        // 建立 ["year/01", "year/02", ... "year/12"] 的 Array()
        let months = (1...12).map { String(format: "\(CalendarHelper().yearString(date: now))/%02d", $0) }
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM"
        for i in months {
            income.append(getTotalIncomeOnSelectedMonth(dateString: i))
        }
        // 設定判斷格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        return income
    }
    
    // 抓取本日的 expense
    // 目前沒有使用到
    func getDailyExpenses() -> [Int] {
        var today = [Int]()
        // 每個支出類別的總和
        var typeEx = 0
        // 抓取所有資料進行比對
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                if dateformatter.string(from: k.date) == dateformatter.string(from: Date()) {
                    typeEx += k.expense
                }
            }
            today.append(typeEx)
            typeEx = 0
        }
        return today
    }
    
    // 抓取本日的 income
    // 目前沒有使用到
    func getDailyIncome() -> [Int] {
        var today = [Int]()
        // 每個支出類別的總和
        var typeIn = 0
        // 抓取所有資料進行比對
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                if dateformatter.string(from: k.date) == dateformatter.string(from: Date()) {
                    typeIn += k.income
                }
            }
            today.append(typeIn)
            typeIn = 0
        }
        
        return today
    }
    
    // 抓取本週每個 expense 的總額
    func getWeekExpenses() -> [Int] {
        // 設定日期格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var week = [Int]()
        // 每個支出類別的總和
        var typeEx = 0
        // 抓取所有資料進行比對
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                if CalendarHelper().getDatesForWeek(date: now).contains(dateformatter.string(from: k.date)) {
                    typeEx += k.expense
                }
            }
            week.append(typeEx)
            typeEx = 0
        }
        return week
    }
    
    // 抓取本週每個 income 的總額
    func getWeekIncome() -> [Int] {
        // 設定日期格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var week = [Int]()
        // 每個支出類別的總和
        var typeIn = 0
        // 抓取所有資料進行比對
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                if CalendarHelper().getDatesForWeek(date: Date()).contains(dateformatter.string(from: k.date)) {
                    typeIn += k.income
                }
            }
            week.append(typeIn)
            typeIn = 0
        }
        return week
    }
    
    // 抓取本月的 expense
    func getMonthExpenses() -> [Int] {
        // 設定日期格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var month = [Int]()
        // 每個支出類別的總和
        var typeEx = 0
        // 抓取所有資料進行比對
        for i in expenseLabel {
            for k in expensetotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                if dateformatter.string(from: k.date).contains(CalendarHelper().yearString(date: now)) {
                    typeEx += k.expense
                }
            }
            month.append(typeEx)
            typeEx = 0
        }
        return month
    }
    
    // 抓取本月的 income
    func getMonthIncome() -> [Int] {
        // 設定日期格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        var month = [Int]()
        // 每個支出類別的總和
        var typeIn = 0
        // 抓取所有資料進行比對
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                if dateformatter.string(from: k.date).contains(CalendarHelper().yearString(date: now)) {
                    typeIn += k.income
                }
            }
            month.append(typeIn)
            typeIn = 0
        }
        return month
    }
    
    
    // 計算 income 每個類別的總額
    func categoryIncome(dateString: String) {
        // 每個支出類別的總和
        var typeIn = 0
        // 抓取所有資料進行比對
        for i in incomeLabel {
            for k in incometotaldata["\(i)"] ?? [] {
                // 判斷是否為指定的日期
                // 轉換為 月份格式
                dateformatter.dateFormat = "yyyy/MM"
                if dateformatter.string(from: k.date) == dateString {
                    typeIn += k.income
                }
            }
            everyIncome.append(typeIn)
            typeIn = 0
        }
        
        // 將日期格式調整回來
        dateformatter.dateFormat = "yyyy/MM/dd"
    }

    
    // LineCharts 設置
    func setLineChart(values: [Int], color: UIColor, lineChartView: LineChartView, label: String) {
        // 確保從 week 切回時產生錯誤，每次都先設為 nil
        lineChartView.xAxis.valueFormatter = nil
        
        // 產生 chartsEntry
        var chartsEntry: [ChartDataEntry] = []
        
        // 細部設定
        // 使用 switch 來決定顯示的標籤
        switch TimeframeSelector {
        // 切換 Day 時，必須改成 x: Double(i+1)
        case "Day":
            for i in 0..<values.count {
                chartsEntry.append(ChartDataEntry(x: Double(i+1), y: Double(values[i])))
            }
        // 切換 week 時，必須改成 x: Double(i)
        case "Week":
            for i in 0..<values.count {
                chartsEntry.append(ChartDataEntry(x: Double(i), y: Double(values[i])))
            }
        // 切換 month 時，必須改成 x: Double(i)
        case "Month":
            for i in 0..<values.count {
                chartsEntry.append(ChartDataEntry(x: Double(i), y: Double(values[i])))
            }
        default :
            print("error")
        }
        
        // 產生 lineChartDataSet
        let lineChartDataSet = LineChartDataSet(entries: chartsEntry, label: label)
        // 改變 line 的顏色
        lineChartDataSet.colors = [color]
        
        // 產生 lineChartData
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        // 利用 LineChartView 顯示 lineChartData
        lineChartView.data = lineChartData
        
        
        // 其它設置
        // MARK: chartDataSet
        // 每個數值上的圓半徑數值
        lineChartDataSet.circleRadius = 0

        // 折線會採用 水平貝塞爾曲線進行平滑處理
        lineChartDataSet.mode = .horizontalBezier

        // 加粗曲線
        lineChartDataSet.lineWidth = 2

        // 關閉點擊後的十字線
        lineChartDataSet.highlightEnabled = true

        //開啟填充色繪製
        lineChartDataSet.drawFilledEnabled = true
        //設置填充色
        lineChartDataSet.fillColor = .blue
        //設置填充色透明度
        lineChartDataSet.fillAlpha = 1

        // 開啟填充色繪製
        lineChartDataSet.drawFilledEnabled = true
        // 漸變顏色數組
        let gradientColors = [color.cgColor, UIColor.white.cgColor] as CFArray
        // 每組顏色所在位置（範圍0~1)
        let colorLocations:[CGFloat] = [1.0, 0.0]
        // 生成漸變色
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: gradientColors, locations: colorLocations)
        //將漸變色作為填充對象
        lineChartDataSet.fill = LinearGradientFill(gradient: gradient!, angle: 90.0)


        // MARK: lineChartView
        // 關閉 x 軸縮放
        lineChartView.scaleXEnabled = false
        // 關閉 y 軸縮放
        lineChartView.scaleYEnabled = false
        // 關閉雙擊縮放
        lineChartView.doubleTapToZoomEnabled = false

        // x 標籤相對於圖表的位置
        lineChartView.xAxis.labelPosition = .bottom

        // 隱藏 x 垂直的隔線
        lineChartView.xAxis.drawGridLinesEnabled = false
        // 在 X 軸上繪製一條水平的軸線
        lineChartView.xAxis.drawAxisLineEnabled = true

        // 隱藏 y 軸水平線
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false

        // 隱藏 LineChartView 中 x 軸上的標籤
//        lineChartView.xAxis.labelTextColor = .clear
        // 隱藏右邊欄位的資料
        lineChartView.rightAxis.enabled = false
        // 隱藏左邊欄位的資料
        lineChartView.leftAxis.enabled = false
        // 隱藏數值文字
        lineChartView.data?.setValueTextColor(.clear)
        
        // 設定 y 軸的最小值, 若沒設定 線會卡在中間顯示
        lineChartView.leftAxis.axisMinimum = 0
        
        // 控制左邊顯示數值的標籤數量
        lineChartView.leftAxis.setLabelCount(5, force: true)

        lineChartView.legend.enabled = false
        
        // 細部設定
        // 使用 switch 來決定顯示的標籤
        switch TimeframeSelector {
        case "Day":
            // 設置 x 軸的標籤數量，這裡設置為 values.count，即所有日期
            lineChartView.xAxis.labelCount = values.count / 5 // 每 5 個點顯示一個數據
            // 設置 x 軸的最小值和最大值，這裡設置為 0 和 6，對應數據的索引範圍
            lineChartView.xAxis.axisMinimum = 1
            lineChartView.xAxis.axisMaximum = Double(values.count)
        case "Week":
            lineChartView.xAxis.labelCount = 7

            // 設置 x 軸的最小值和最大值，這裡設置為 0 和 6，對應數據的索引範圍
            lineChartView.xAxis.axisMinimum = 0
            lineChartView.xAxis.axisMaximum = 6

            // 強制顯示所有標籤
            lineChartView.xAxis.forceLabelsEnabled = true
            
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: CalendarHelper().getDatesForWeekWithoutyear(date: now))
        case "Month":
            lineChartView.xAxis.labelCount = 12

            // 設置 x 軸的最小值和最大值，這裡設置為 0 和 11，對應數據的索引範圍
            lineChartView.xAxis.axisMinimum = 0
            lineChartView.xAxis.axisMaximum = 11

            // 強制顯示所有標籤
            lineChartView.xAxis.forceLabelsEnabled = true
            // 製作
            // 建立 ["year/01", "year/02", ... "year/12"] 的 Array()
            let months = (1...12).map { String(format: "\(CalendarHelper().yearString(date: now))/%02d", $0) }
            
            var value = [String]()
            // 轉換日期格式
            dateformatter.dateFormat = "yyyy/MM"
            for i in months {
                let dd = dateformatter.date(from: i)!
                // 轉換成 MMM
                dateformatter.dateFormat = "MMM"
                value.append(dateformatter.string(from: dd))
                // 轉換成 yyyy/MM
                dateformatter.dateFormat = "yyyy/MM"
            }
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: value)
        default:
            print("error")
        }
        
        
        

        
    }
    
    // BarCharts 設置
    func setBarChart(dataPoints: [String], values: [Int], barChartView: BarChartView) {
        // 產生 barChartEntry
        var dataEntry:[BarChartDataEntry] = []
        
        // 保存每筆資料的顏色
        var valueColors = [UIColor]()
        let threshold: Double = 0
        
        // 產生 每筆 barChartDataEntry
        for i in 0..<dataPoints.count {
            dataEntry.append(BarChartDataEntry(x: Double(i), y: Double(values[i])))
            // 小於 0 的金額，字體顏色就設定為 clear
            if Double(values[i]) > threshold {
                valueColors.append(.black)
            }else {
                valueColors.append(.clear)
            }
        }
        
        // 產生 barChartDataSet
        let barChartDataSet = BarChartDataSet(entries: dataEntry, label: "")
        barChartDataSet.colors = colors
        
        // 將顯示的數字指定成 valueColors 中的顏色
        barChartDataSet.valueColors = valueColors
        
        // 產生 barChartData
        let barChartData = BarChartData(dataSet: barChartDataSet)

        // 利用 BarChartView 顯示 lineChartData
        barChartView.data = barChartData
        
        // 將 x 方向的格式修改成我們設定的字串
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        
        // 隱藏 x 垂直的隔線
        barChartView.xAxis.drawGridLinesEnabled = false
        // 在 X 軸上繪製一條水平的軸線
        barChartView.xAxis.drawAxisLineEnabled = true

        // 隱藏 y 軸水平線
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false

        // x 標籤相對於圖表的位置
        barChartView.xAxis.labelPosition = .bottom
        // 隱藏右邊欄位的資料
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        // 關閉點擊後的十字線
        barChartDataSet.highlightEnabled = false


        // 關閉 x 軸縮放
        barChartView.scaleXEnabled = false
        // 關閉 y 軸縮放
        barChartView.scaleYEnabled = false
        // 關閉雙擊縮放
        barChartView.doubleTapToZoomEnabled = false
        
        // 隱藏 legend (左下角的說明)
        barChartView.legend.enabled = false
        
        // 設定 y 軸的最小值
        barChartView.leftAxis.axisMinimum = 0
        
        // 控制左邊顯示數值的標籤數量
        barChartView.leftAxis.setLabelCount(5, force: true)

    }
    
    // 更新所有的 Chart
    func updateAllChart(dateString: String) {
        
        // 移除 每日的總額
        everyDateExpense.removeAll()
        everyDateIncome.removeAll()
        // 移除 每個類別的總額
        everyExpense.removeAll()
        everyIncome.removeAll()
        
        
        // 計算『每日』的 income, expense 總額
        dailyIncome(dateString: dateString)
        dailyExpense(dateString: dateString)
        
        // 計算每個『類別』的 income, expense 總額
        categoryExpense(dateString: dateString)
        categoryIncome(dateString: dateString)

        
        // 判斷目前顯示 月 週 日 的資料
        switch TimeframeSelector {
        case "Day":
            // expense LineChart
            if chartDisplayType == "ex" {
                setLineChart(values: everyDateExpense, color: .systemRed, lineChartView: ExandInLineChartView, label: "Expense")
            }else {
            // income LineChart
                setLineChart(values: everyDateIncome, color: .systemGreen, lineChartView: ExandInLineChartView, label: "Income")
            }
            setBarChart(dataPoints: expenseLabel, values: everyExpense, barChartView: expenseBarChartView)
            setBarChart(dataPoints: incomeLabel, values: everyIncome, barChartView: incomeBarChartView)
            
            // 更新顯示的 expense, income, total label
            expenseUILabel.text = "\(everyExpense.reduce(0, +))"
            incomeUILabel.text = "\(everyIncome.reduce(0, +))"
            totalLabel.text = "\(everyIncome.reduce(0, +) - everyExpense.reduce(0, +))"
        case "Week":
            // expense LineChart
            if chartDisplayType == "ex" {
                setLineChart(values: 一週支出(day: dateformatter.string(from: now)), color: .systemRed, lineChartView: ExandInLineChartView, label: "Expense")
            }else {
                // income LineChart
                setLineChart(values: 一週收入(day: dateformatter.string(from: now)), color: .systemGreen, lineChartView: ExandInLineChartView, label: "Income")
            }
            // 直方圖
            setBarChart(dataPoints: expenseLabel, values: getWeekExpenses(), barChartView: expenseBarChartView)
            setBarChart(dataPoints: incomeLabel, values: getWeekIncome(), barChartView: incomeBarChartView)
            
            // 更新顯示的 expense, income, total label
            expenseUILabel.text = "\(getWeekExpenses().reduce(0, +))"
            incomeUILabel.text = "\(getWeekIncome().reduce(0, +))"
            totalLabel.text = "\(getWeekIncome().reduce(0, +) - getWeekExpenses().reduce(0, +))"
        case "Month":
            // expense LineChart
            if chartDisplayType == "ex" {
                setLineChart(values: 一年支出(day: dateformatter.string(from: now)), color: .systemRed, lineChartView: ExandInLineChartView, label: "Expense")
            }else {
                // income LineChart
                setLineChart(values: 一年收入(day: dateformatter.string(from: now)), color: .systemGreen, lineChartView: ExandInLineChartView, label: "Income")
            }
            // 直方圖
            setBarChart(dataPoints: expenseLabel, values: getMonthExpenses(), barChartView: expenseBarChartView)
            setBarChart(dataPoints: incomeLabel, values: getMonthIncome(), barChartView: incomeBarChartView)
            
            // 更新顯示的 expense, income, total label
            expenseUILabel.text = "\(getMonthExpenses().reduce(0, +))"
            incomeUILabel.text = "\(getMonthIncome().reduce(0, +))"
            totalLabel.text = "\(getMonthIncome().reduce(0, +) - getMonthExpenses().reduce(0, +))"
        default:
            print("Error")
        }
    }
    

    @IBAction func nextMonth(_ sender: UIButton) {
        now = CalendarHelper().plusMonth(date: now)

        // 更新 月份與年份
        dateformatter.dateFormat = "yyyy,MMM"
        changeDateButton.setTitle(dateformatter.string(from: now), for: .normal)
        
        dateformatter.dateFormat = "yyyy/MM"
        dateString = dateformatter.string(from: now)

        // 更新所有 chart
        updateAllChart(dateString: dateString)

    }
    
    
    @IBAction func previousMonth(_ sender: UIButton) {
        
        now = CalendarHelper().minusMonth(date: now)
        
        // 更新 月份與年份
        dateformatter.dateFormat = "yyyy,MMM"
        changeDateButton.setTitle(dateformatter.string(from: now), for: .normal)
        
        dateformatter.dateFormat = "yyyy/MM"
        dateString = dateformatter.string(from: now)
        
        // 更新所有 chart
        updateAllChart(dateString: dateString)
        
    }
    
    
    @IBAction func changeExpenseChart(_ sender: UIButton) {
        // 按鈕切換
        setButton(button: sender, .systemRed)
        setButton(button: incomeButton, .systemGray)
        chartDisplayType = "ex"
        setLineChart(values: everyDateExpense, color: .systemRed, lineChartView: ExandInLineChartView, label: "Expense")
        // 更新所有的圖表
        updateAllChart(dateString: dateString)
    }
    
    @IBAction func changeIncomeChart(_ sender: UIButton) {
        // 按鈕切換
        setButton(button: sender, .systemGreen)
        setButton(button: expenseButton, .systemGray)
        chartDisplayType = "in"
        setLineChart(values: everyDateIncome, color: .systemGreen, lineChartView: ExandInLineChartView, label: "Income")
        // 更新所有的圖表
        updateAllChart(dateString: dateString)

    }
    
}
