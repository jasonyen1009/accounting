//
//  ChartViewController.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2023/2/17.
//

import UIKit
import Charts

class ChartViewController: UIViewController {


    @IBOutlet weak var expenseLineChartView: LineChartView!
    @IBOutlet weak var incomeLineChartView: LineChartView!
    
    @IBOutlet weak var expenseBarChartView: BarChartView!
    @IBOutlet weak var incomeBarChartView: BarChartView!
    
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
        
        
        
        print("本月的日期數量 totalSquares", CalendarHelper().daysInMonth(date: now))
        
        // 設定初始畫面的月份字串 格式
        dateformatter.dateFormat = "yyyy/MM"
        dateString = dateformatter.string(from: now)
        
        //
        // 暫時設定的日期
        dateString = "2023/02"
        
        // 設定抓取 expensetotaldata, incometotaldata 日期格式
        dateformatter.dateFormat = "yyyy/MM/dd"
        
        
        // 計算『每日』的 income, expense 總額
        dailyIncome()
        dailyExpense()
        
        // 計算每個『類別』的 income, expense 總額
        categoryExpense()
        categoryIncome()
        
        
        // 設定 折線圖 表格
        setLineChart(values: everyDateExpense, color: .systemRed, lineChartView: expenseLineChartView, label: "Expense")
        setLineChart(values: everyDateIncome, color: .systemGreen, lineChartView: incomeLineChartView, label: "Income")
        
        // 設定 直方圖 表格
        setBarChart(dataPoints: expenseLabel, values: everyExpense, barChartView: expenseBarChartView)
        setBarChart(dataPoints: incomeLabel, values: everyIncome, barChartView: incomeBarChartView)
        
        
    }
    
    // 計算 expense 每日的總額
    func dailyExpense() {
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
                            
                            print(dateformatter.string(from: k.date))
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
    func dailyIncome() {
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
    func categoryExpense() {
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
    
    // 計算 income 每個類別的總額
    func categoryIncome() {
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
        // 產生 chartsEntry
        var chartsEntry: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            chartsEntry.append(ChartDataEntry(x: Double(i+1), y: Double(values[i])))
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
        lineChartView.leftAxis.enabled = true
        // 隱藏數值文字
        lineChartView.data?.setValueTextColor(.clear)
        
    }
    
    // BarCharts 設置
    func setBarChart(dataPoints: [String], values: [Int], barChartView: BarChartView) {
        // 產生 barChartEntry
        var dataEntry:[BarChartDataEntry] = []
        
        // 產生 每筆 barChartDataEntry
        for i in 0..<dataPoints.count {
            dataEntry.append(BarChartDataEntry(x: Double(i), y: Double(values[i])))
        }
        
        // 產生 barChartDataSet
        let barChartDataSet = BarChartDataSet(entries: dataEntry, label: "")
        barChartDataSet.colors = colors
        
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
        
    }


}
