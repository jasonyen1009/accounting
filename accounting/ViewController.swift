//
//  ViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/4/19.
//

import UIKit
import Charts

class ViewController: UIViewController {

    // Time
    var time = Timer()
    
    // 取得目前的時間
    var now = Date()
    let dateformatter = DateFormatter()
    
    
    // 支出種類
    var expenseLabel = ["個人", "飲食", "購物", "交通", "醫療", "生活"]
    var incomeLabel = ["薪水", "利息", "投資", "收租", "買賣", "娛樂"]
    
    // years, months
    var years = ["2021", "2022", "2023", "2024", "2025", "2026"]
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    // 所有支出總計
    var expensetotaldata = [
        "個人": [Expense](),
        "飲食": [Expense](),
        "購物": [Expense](),
        "交通": [Expense](),
        "醫療": [Expense](),
        "生活": [Expense]()
    
    ] {
        didSet {
            Expense.SaveExpense(expensetotaldata)
            // 發送 Expense 更新通知
            NotificationCenter.default.post(name: AllNotification.updateEXorINFromViewControlller, object: nil)
        }
    }
    
    // 所有收入總計
    var incometotaldata = [
        "薪水": [Income](),
        "利息": [Income](),
        "投資": [Income](),
        "收租": [Income](),
        "買賣": [Income](),
        "娛樂": [Income]()
    ] {
        didSet {
            Income.SaveIncome(incometotaldata)
            // 發送 Income 更新通知
            NotificationCenter.default.post(name: AllNotification.updateEXorINFromViewControlller, object: nil)
        }
    }
    
    
    // 圖表顏色
    let colors = [
        UIColor(red: 67/255, green: 97/255, blue: 238/255, alpha: 1).cgColor,
        UIColor(red: 63/255, green: 55/255, blue: 201/255, alpha: 1).cgColor,
        UIColor(red: 58/255, green: 12/255, blue: 163/255, alpha: 1).cgColor,
        UIColor(red: 114/255, green: 9/255, blue: 183/255, alpha: 1).cgColor,
        UIColor(red: 181/255, green: 23/255, blue: 158/255, alpha: 1).cgColor,
        UIColor(red: 247/255, green: 37/255, blue: 133/255, alpha: 1).cgColor
    ]
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var tableviewheightconstraint: NSLayoutConstraint!
    @IBOutlet weak var changeDateButton: UIButton!
    @IBOutlet weak var changetypeSegmentedControl: UISegmentedControl!
    
    
    // Pickerview
    let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))

    
    var expense: Expense?
    var income: Income?
    
    // 每個類別的總額
    var everyExpense: [Int] = []
    var everyIncome: [Int] = []
    
    // pieChart
    var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 判斷系統的語言是否為中文，若為中文 months 必須改為下方格式，不改的話 日期格式對不上會閃退
        if let language = Locale.preferredLanguages.first, language.contains("zh-Hant") {
            months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
            print("目前的系統語言：中文")
        } else {
            print("目前的系統語言：英文")
        }
        
        
        // 設置 dateformatter 格式
        dateformatter.dateFormat = "yyyy,MMM"
        
        // 將 Button 日期設為 當前年月份
        changeDateButton.setTitle("\(dateformatter.string(from: now))", for: .normal)
        
        // 取得儲存 expense 的資料
        if let expense = Expense.loadExpense() {
            self.expensetotaldata = expense
        }
        
        // 取得儲存 income 的資料
        if let income = Income.loadIncome() {
            self.incometotaldata = income
        }

        // tableview 高度設定為 view 的 2/5
        tableviewheightconstraint.constant = view.frame.height * 0.4
        
        // TableView
        myTableView.dataSource = self
        myTableView.delegate = self
        
        // PickerView
        pickerView.dataSource = self
        pickerView.delegate = self
        
        
        
        // 設定 NavigationBar 顏色
        let standardAppearance = UINavigationBarAppearance()

            // Title font color
            standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            // prevent Nav Bar color change on scroll view push behind NavBar
            standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor.systemGray6

            self.navigationController?.navigationBar.standardAppearance = standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        
        // 接收 CalenderViewController 更新 Expense, Income 通知
        NotificationCenter.default.addObserver(self, selector: #selector(updateExorIn(noti: )), name: AllNotification.updateEXorINFromCalenderViewController, object: nil)

        // 畫面更新
        updateUI()

              
    }
    
    // 再次讀取最新的資料，並重新更新所有畫面
    @objc func updateExorIn(noti: Notification) {
        
        // 取得儲存 expense 的資料
        if let expense = Expense.loadExpense() {
            self.expensetotaldata = expense
        }
        // 取得儲存 income 的資料
        if let income = Income.loadIncome() {
            self.incometotaldata = income
        }
        updateUI()
        
    }
    
    // 點選 cancel 返回
    @IBAction func unwindTopcancel(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // 點選 Done 返回
    @IBAction func unwindToDone(_ unwindSegue: UIStoryboardSegue) {
        
        if let source = unwindSegue.source as? HomeViewController ,
           let data = source.homedata  {
            print(data)
            
            // 進行 型別 判斷
            if type(of: data) == Expense.self {
                // 若 資料 型別為 Expense 轉型為 Expsense
                expense = data as? Expense
                // 若沒有新增消費名稱，就使用消費類別當作名稱
                let type = expense!.expensetype
                if expense?.expensename == "" {
                    expense?.expensename = type
                }
                // 若為預設備忘錄字串，將清空
                if expense?.note == "備忘錄" {
                    expense?.note = ""
                }
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
            }else {
                // 非 Expense 轉型為 Income
                income = data as? Income
                // 若沒有新增收入名稱，就使用收入類別當作名稱
                let type = income!.incometype
                if income?.incomename == "" {
                    income?.incomename = type
                }
                // 若為預設備忘錄字串，將清空
                if income?.note == "備忘錄" {
                    income?.note = ""
                }
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
            }
            
            // 畫面更新
            updateUI()
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ListTableViewController {
            // 成為 ListTableViewControllerDelegate delegate
            switch changetypeSegmentedControl.selectedSegmentIndex {
            case 0:
                controller.expensedelegate = self
            default :
                controller.incomedelegate = self
            }
        }
    }
    
    // alertcontroller + pickerview
    @IBAction func showAlertController(_ sender: Any) {
        
        // 設定一個 viewcontroller
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        // 將 pickerview 加入到 vc 的 view 中
        vc.view.addSubview(pickerView)
        
        // 取得目前月份
        dateformatter.dateFormat = "MMM"
        let newmonth = dateformatter.string(from: now)
        // 取得目前年份
        dateformatter.dateFormat = "yyyy"
        let newyear = dateformatter.string(from: now)
        // 取得資料後，必須將格式轉回
        dateformatter.dateFormat = "yyyy,MMM"
        
        
        // 設定初始 pickerview 各個 components row 的位置
        // 利用 .firstIndex(of: newmonth) 取得 index 並回傳
        // 同步 month 位置
        pickerView.selectRow(months.firstIndex(of: newmonth) ?? 0, inComponent: 1, animated: true)
        // 同步 year 位置
        pickerView.selectRow(years.firstIndex(of: newyear) ?? 0, inComponent: 0, animated: true)
        
        
        // AlertController
        let alertcontroller = UIAlertController(title: "Choose Date", message: "", preferredStyle: .alert)
        // 最重要的一步驟
        // 如果少了 setValue, pickerview 將不會顯示
        alertcontroller.setValue(vc, forKey: "contentViewController")
        alertcontroller.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertcontroller.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            
            // pickerview
            // 如果將 year, month 放在 本事件外面
            // button 同步的字會不同調
            let year = self.pickerView.selectedRow(inComponent: 0)
            let month = self.pickerView.selectedRow(inComponent: 1)
            let newdate = "\(self.years[year]),\(self.months[month])"
            
            // 將 pickerview 日期, 同步到 Button 上
            self.changeDateButton.setTitle(newdate, for: .normal)
            
            // 將 newdate 同步到 now 上
            let updatedate = self.dateformatter.date(from: newdate)
            self.now = updatedate!
            
            
            // 畫面更新
            self.updateUI()
        }))
        present(alertcontroller, animated: true)
    }
    
    // 常壓 button 回到目前的年月份
    @IBAction func shownowdate(_ sender: Any) {
        changeDateButton.setTitle(dateformatter.string(from: Date()), for: .normal)
        now = Date()
        updateUI()
    }
    
    // 傳資料到 ListTableViewController
    @IBSegueAction func Senddata(_ coder: NSCoder) -> ListTableViewController? {
        
        // 判斷點選哪一個 row 來傳遞點選到的 data
        if let row = myTableView.indexPathForSelectedRow?.row {
            switch changetypeSegmentedControl.selectedSegmentIndex {
            case 0:
                return ListTableViewController(coder: coder, list: expensetotaldata["\(expenseLabel[row])"] ?? [], date: now, index: 0)
            default :
                return ListTableViewController(coder: coder, list: incometotaldata["\(incomeLabel[row])"] ?? [], date: now, index: 1)
            }
//            return ListTableViewController(coder: coder, list: expensetotaldata["\(expenseLabel[row])"] ?? [], date: now)
        }else {
            return nil
        }
    }
    
    // 切換 segmentedcontrol 觸發
    @IBAction func changeUI(_ sender: UISegmentedControl) {
        updateUI()
        myTableView.reloadData()

    }
    

    
    // 收鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // 數字轉為金錢格式文字
    func moneyString(_ money: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        return formatter.string(from: NSNumber(value: money)) ?? ""
    }
    
    
    // 所有畫面資料更新
    func updateUI() {
        // 畫面更新
        
        // 若有 pieChartView 就刪除
        if let pieChartView = pieChartView {
            pieChartView.removeFromSuperview()

        }

        // 在產生每次的 chart 前，都先移除 expense, income
        everyExpense.removeAll()
        everyIncome.removeAll()
        
        dateformatter.dateFormat = "yyyy/MM"
        // 計算每筆類別的 expense, income
        categoryExpense(dateString: dateformatter.string(from: now))
        categoryIncome(dateString: dateformatter.string(from: now))
        // 計算完後，必須將日期格式調整回來
        dateformatter.dateFormat = "yyyy,MMM"
        
        // 判斷要顯示的 Charts
        switch changetypeSegmentedControl.selectedSegmentIndex {
        case 0:
            // 產生 expense pieChartView
            // 判斷目前語言是否為英文
            if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
                createPieChart(dataPoints: ["personal", "dietary", "shopping", "traffic", "medical", "life"], values: everyExpense)
            }else {
                createPieChart(dataPoints: expenseLabel, values: everyExpense)
            }
        default :
            // 產生 income pieChartView
            // 判斷目前語言是否為英文
            if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
                createPieChart(dataPoints: ["salary", "interest", "invest", "rent", "transaction", "play"], values: everyIncome)
            }else {
                createPieChart(dataPoints: incomeLabel, values: everyIncome)
            }
        }
        
        myTableView.reloadData()
        
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

    }
    

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 決定表格數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenseLabel.count
    }
    
    // 決定表格內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! ExpensetypeTableViewCell
        
        let enEx = ["personal", "dietary", "shopping", "traffic", "medical", "life"]
        let exIN = ["salary", "interest", "invest", "rent", "transaction", "play"]
        
        // 自訂的 cell
        switch changetypeSegmentedControl.selectedSegmentIndex {
        // 支出頁面
        case 0:
            // 判斷目前語言是否為英文
            if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
                cell.celltypeLabel.text = "\(enEx[indexPath.row])"
            }else {
                cell.celltypeLabel.text = "\(expenseLabel[indexPath.row])"
                cell.celltypeLabel.font = UIFont(name: "", size: 15)
            }
            
            cell.cellmoneyLabel.text = "\(moneyString(Int(everyExpense[indexPath.row])))"
            
            cell.circleview.backgroundColor = UIColor(cgColor: colors[indexPath.row])

            // 暫時隱藏
            cell.percentageLabel.text = ""
            
        // 收入頁面
        default :
            // 判斷目前語言是否為英文
            if let language = Locale.preferredLanguages.first, !language.contains("zh-Hant") {
                cell.celltypeLabel.text = "\(exIN[indexPath.row])"
            }else {
                cell.celltypeLabel.text = "\(incomeLabel[indexPath.row])"
            }
            cell.cellmoneyLabel.text = "\(moneyString(Int(everyIncome[indexPath.row])))"
            
            cell.circleview.backgroundColor = UIColor(cgColor: colors[indexPath.row])
            // 暫時隱藏
            cell.percentageLabel.text = ""

        }
        
        return cell
    }

}

// PickerView
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 決定有幾項 components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    // 決定每項 components 中 Row 數量
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return years.count
        }
        return months.count
    }
    
    // 決定每項 Row 的字
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0{
            return years[row]
        }
        return months[row]
    }
    
    // pickerview 選取事件
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = pickerView.selectedRow(inComponent: 0)
        let month = pickerView.selectedRow(inComponent: 1)
        let newdate = "\(years[year]),\(months[month])"
        // 將所選的日期, 同步到 now
        now = dateformatter.date(from: newdate) ?? Date()
    }
}

// ListTableViewControllerDelegate
extension ViewController: ExpenseListTableViewControllerDelegate {
    
    func listTableViewController(_ controller: ListTableViewController, didEdit data: [String : [Expense]]) {
        
        // 將新資料與 totaldata 總資料一起同步
        expensetotaldata[data.keys.first!] = data[data.keys.first!]
        // 畫面更新
        updateUI()
    }
    
    
    
}

extension ViewController: IncomeListTableViewControllerDelegate {
    func incomeListTableViewControllerDelegate(_ controller: ListTableViewController, didEdit data: [String : [Income]]) {
        
        // 將新資料與 totaldata 總資料一起同步
        incometotaldata[data.keys.first!] = data[data.keys.first!]
        // 畫面更新
        updateUI()
    }
    
    
}

// Chart
extension ViewController: ChartViewDelegate {
    // 首先計算 `x` 座標為 `view.frame.midX - 75`，表示將 `PieChartView` 的水平中心位置設定為 `view` 的水平中心減去一半的 `width`。同樣地，`y` 座標為 `view.frame.midY - 75`，表示將 `PieChartView` 的垂直中心位置設定為 `view` 的垂直中心減去一半的 `height`。最後，`width` 和 `height` 都設定為 150，從而讓 `PieChartView` 的大小為 150x150
    // 建立空白的 pieChartView
    func createPieChart(dataPoints: [String], values: [Int]) {
        if view.frame.height < 700 {
            pieChartView = PieChartView(frame: CGRect(x: view.frame.midX - (view.frame.width / 2), y: view.frame.midY - 250, width: view.frame.width, height: 250))
        // 配合 SE 大小
        }else {
            pieChartView = PieChartView(frame: CGRect(x: view.frame.midX - (view.frame.width / 2), y: view.frame.midY - 300, width: view.frame.width, height: 300))
        }
        
        pieChartView.delegate = self
        view.addSubview(pieChartView)
        
        // 產生 PieChartDataEntry
        var dataEntries: [PieChartDataEntry] = []
        
        // 產生 PieChartDataEntry 每筆資料
        for i in 0..<dataPoints.count {
            dataEntries.append(PieChartDataEntry(value: Double(values[i]), label: dataPoints[i]))
        }
        // 產生 PieChartDataSet
        let piechartdataset = PieChartDataSet(entries: dataEntries, label: "")
        // 改變 chart 顏色
        piechartdataset.colors = colors.map { UIColor(cgColor: $0)}
        // 產生 Data
        let piechartdata = PieChartData(dataSet: piechartdataset)
        // 利用 ChartsView 顯示 BarChartData
        pieChartView.data = piechartdata
        
        // 其它 設置
        // 設置 piechartview 中間顏色
        pieChartView.holeColor = .clear
        
        // 設置圓餅圖中間的顯示文字 !!!!!
        pieChartView.centerText = "TWD \(values.map({ $0 }).reduce(0, { $0 + $1 }))"
        // 改變扇區延伸長度
        piechartdataset.selectionShift = 0
        
        // 字體修改
        piechartdata.setValueFont(.systemFont(ofSize: 10, weight: .medium))

        // 字體顏色修改
        piechartdata.setValueTextColor(.black)
        
        // 將數值轉為百分比
        pieChartView.usePercentValuesEnabled = true
        
        //数值百分比格式化显示
        let pFormatter = NumberFormatter()
        // 設置 numberStyle 屬性為 .percent，以將數字轉換為百分比格式
        pFormatter.numberStyle = .percent
        // 設置 maximumFractionDigits 屬性為 1，以限制小數點後的位數為 1
        pFormatter.maximumFractionDigits = 1
        // multiplier 屬性被設置為 1，以將數字轉換為百分比
        pFormatter.multiplier = 1
        // 設置 percentSymbol 屬性為 "%"，以在百分比值後添加百分比符號
        pFormatter.percentSymbol = "%"
        // 使用 setValueFormatter 方法來將格式化器應用於餅圖的數據中
        // 使用 DefaultValueFormatter 類創建一個新的格式化器，並將其初始化為 pFormatter
        piechartdata.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        piechartdataset.yValuePosition = .outsideSlice

        //legend
        let legend = pieChartView.legend
        // 設置圖例的水平對齊方式為中心
        legend.horizontalAlignment = .center
        // 設置圖例的垂直對齊方式為底部
        legend.verticalAlignment = .bottom
        // 設置圖例的方向為水平方向
        legend.orientation = .horizontal
        
    }
    
    
}
