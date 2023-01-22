//
//  ViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/4/19.
//

import UIKit

class ViewController: UIViewController {

    // Time
    var time = Timer()
    
    // 取得目前的時間
    var now = Date()
    let dateformatter = DateFormatter()
    
    // 支出總覽 display
    var displayexpense = Totalexpense(personal: 0, dietary: 0, shopping: 0, traffic: 0, medical: 0, life: 0)
    // 收入總覽 display
    var displayincome = Totalincome(salary: 0, interest: 0, invest: 0, rent: 0, transaction: 0, play: 0)
    
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
            NotificationCenter.default.post(name: AllNotification.updateEXorIN, object: nil)
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
            NotificationCenter.default.post(name: AllNotification.updateEXorIN, object: nil)
        }
    }
    
    // 支出總額
    var expenseamount = 0
    // 收入總額
    var incomeamount = 0
    
    // 支出顯示總額
    var displayexpenseamount = 0
    // 收入顯示總額
    var displayincomeamount = 0
    
    
    let totalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    // 角度
    let aDegree = CGFloat.pi / 180
    // 圖的位置
    var position = CGPoint()
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
    
    var percentageLayers = [CALayer]()
    var percentageTable = [CALayer]()
    var percentageLabel = [UILabel]()


    var expense: Expense?
    var income: Income?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定圖的位置設置
        position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 150)
        
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
        
        creatcirclePath()
        creatpercentageLabel()
//        print(myasset)
        
        // 設定 NavigationBar 顏色
        let standardAppearance = UINavigationBarAppearance()

            // Title font color
            standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            // prevent Nav Bar color change on scroll view push behind NavBar
            standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor.systemGray6

            self.navigationController?.navigationBar.standardAppearance = standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        // 畫面更新
        updateUI()

    }
    
    // 點選 cancel 返回
    @IBAction func unwindTopcancel(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // 點選 Done 返回
    @IBAction func unwindToDone(_ unwindSegue: UIStoryboardSegue) {
        print("get")
//        let sourceViewController = unwindSegue.source
        if let source = unwindSegue.source as? HomeViewController ,
           let data = source.homedata  {
            print(data)
            
            // 進行 型別 判斷
            if type(of: data) == Expense.self {
                // 若 資料 型別為 Expense 轉型為 Expsense
                expense = data as? Expense
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
//            controller.delegate = self
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
//            dateformatter.dateFormat = "yyyy,MMM"
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
        creatcirclePath()
        creatpercentageLabel()
        updateUI()
        myTableView.reloadData()
        
    }
    
    // 計算總和
    func calculateall() {
        var total = 0
        for label in expenseLabel {
            for value in expensetotaldata["\(label)"] ?? [] {
                total += value.expense
            }
        }
        expenseamount = total
        
        total = 0
        for label in incomeLabel {
            for value in incometotaldata["\(label)"] ?? [] {
                total += value.income
            }
        }
        incomeamount = total
        
    }
    
    
    // 最底層的 percentage
    func creatcirclePath() {
        let circlePath = UIBezierPath(arcCenter: position, radius: 90, startAngle: aDegree * 270, endAngle: aDegree * (270 + 360), clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        circleLayer.lineWidth = 40
        view.layer.addSublayer(circleLayer)
        percentageLayers.append(circleLayer)
    }
    
    // 初始金額
    func creatpercentageLabel() {
        totalLabel.text = moneyString(0)
        totalLabel.font = UIFont.systemFont(ofSize: 15)
        totalLabel.sizeToFit()
        totalLabel.layer.position = position
        view.addSubview(totalLabel)
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
    
    // 用於所有畫面更新
    // 計算各個消費 expense 總和
    func expensecalculate(_ expensetype: String, date: Date) -> Int {
        var expense = 0
        for i in expensetotaldata[expensetype]! {
            // 判斷是否為 本月的月份
            if dateformatter.string(from: i.date) == dateformatter.string(from: date) {
                expense += i.expense
            }
        }
        displayexpenseamount += expense
        return expense
    }
    // 計算各個消費 income 總和
    func incomecalculate(_ incometype: String, date: Date) -> Int {
        var income = 0
        for i in incometotaldata[incometype]! {
            // 判斷是否為 本月的月份
            if dateformatter.string(from: i.date) == dateformatter.string(from: date) {
                income += i.income
            }
        }
        displayincomeamount += income
        return income
    }
    
    
    // 所有畫面資料更新
    func updateUI() {
        // 畫面更新

        // 每次更新畫面必須設為 0 , 否則每次金額都會累積加上去
        displayexpenseamount = 0
        displayincomeamount = 0
        
        displayexpense.personal = expensecalculate("個人", date: now)
        displayexpense.dietary = expensecalculate("飲食",date: now)
        displayexpense.shopping = expensecalculate("購物",date: now)
        displayexpense.traffic = expensecalculate("交通",date: now)
        displayexpense.medical = expensecalculate("醫療",date: now)
        displayexpense.life = expensecalculate("生活",date: now)
        
        displayincome.salary = incomecalculate("薪水",date: now)
        displayincome.interest = incomecalculate("利息",date: now)
        displayincome.invest = incomecalculate("投資",date: now)
        displayincome.rent = incomecalculate("收租",date: now)
        displayincome.transaction = incomecalculate("買賣",date: now)
        displayincome.play = incomecalculate("娛樂",date: now)
        
        // 選擇要顯示的總和
        switch changetypeSegmentedControl.selectedSegmentIndex {
        case 0:
            totalLabel.text = moneyString(displayexpenseamount)
        default :
            totalLabel.text = moneyString(displayincomeamount)
        }
        
//        totalLabel.text = moneyString(expenseamount)
        
        
        totalLabel.sizeToFit()
        // 這邊必須再次設定 position，不然位置會跑掉
        totalLabel.layer.position = position
        
        // 刪除所有 perentageLayers
        for deleteLayer  in percentageLayers{
            deleteLayer.removeFromSuperlayer()
        }
        percentageLayers.removeAll()
        
        // 刪除所有 percentageLabel
        for deleteLabel in percentageLabel {
            deleteLabel.removeFromSuperview()
        }
        percentageLabel.removeAll()
        
        // 若總額為 0 , 製作底層
        if expenseamount == 0 {
            creatcirclePath()
        }
                    
        // 更新 圖表
        var startDegree: CGFloat = 270
        // expensepercentages
        let expensepercentages = [
            Double(displayexpense.personal),
            Double(displayexpense.dietary),
            Double(displayexpense.shopping),
            Double(displayexpense.traffic),
            Double(displayexpense.medical),
            Double(displayexpense.life)
        ]
        // incomepercentages
        let incomepercentages = [
            Double(displayincome.salary),
            Double(displayincome.interest),
            Double(displayincome.invest),
            Double(displayincome.rent),
            Double(displayincome.transaction),
            Double(displayincome.play)
        ]
        
        switch changetypeSegmentedControl.selectedSegmentIndex {
        case 0:
            // 繪製 各項比例圖表及文字
            for (index, percentage) in expensepercentages.enumerated() {
                // percentages.reduce(0, +) 取得 percentages 總數
                let endDegree = startDegree + (percentage / expensepercentages.reduce(0, +)) * 360
                let percentagePath = UIBezierPath(arcCenter: position, radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * endDegree, clockwise: true)

                let percentageLayer = CAShapeLayer()
                percentageLayer.path = percentagePath.cgPath
                percentageLayer.fillColor = UIColor.clear.cgColor
                percentageLayer.lineWidth = 40
                percentageLayer.strokeColor = colors[index]

                // textlabel 座標
                let textPath = UIBezierPath(arcCenter: position, radius: 125, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + (percentage / expensepercentages.reduce(0, +)) * 180), clockwise: true)
                
                // label 製作
                let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                textLabel.font = UIFont.systemFont(ofSize: 10)
                
                // assetLabel2 垂直顯示
                textLabel.text = "\(expenseLabel[index])"
                textLabel.numberOfLines = 0
                textLabel.sizeToFit()

                // 如果將 textLabel.center = textPath.currentPoint
                // 移動至判斷式外，回傳資料都 0 時，將造成閃退
                if percentage > 0.0 {
                    textLabel.center = textPath.currentPoint
                    view.addSubview(textLabel)
                    percentageLabel.append(textLabel)

                }
                view.layer.addSublayer(percentageLayer)
                percentageLayers.append(percentageLayer)
                startDegree = endDegree
            }
        default :
            // 繪製 各項比例圖表及文字
            for (index, percentage) in incomepercentages.enumerated() {
                // percentages.reduce(0, +) 取得 percentages 總數
                let endDegree = startDegree + (percentage / incomepercentages.reduce(0, +)) * 360
                let percentagePath = UIBezierPath(arcCenter: position, radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * endDegree, clockwise: true)

                let percentageLayer = CAShapeLayer()
                percentageLayer.path = percentagePath.cgPath
                percentageLayer.fillColor = UIColor.clear.cgColor
                percentageLayer.lineWidth = 40
                percentageLayer.strokeColor = colors[index]

                // textlabel 座標
                let textPath = UIBezierPath(arcCenter: position, radius: 125, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + (percentage / incomepercentages.reduce(0, +)) * 180), clockwise: true)
                
                // label 製作
                let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                textLabel.font = UIFont.systemFont(ofSize: 10)
                
                // assetLabel2 垂直顯示
                textLabel.text = "\(incomeLabel[index])"
                textLabel.numberOfLines = 0
                textLabel.sizeToFit()

                // 如果將 textLabel.center = textPath.currentPoint
                // 移動至判斷式外，回傳資料都 0 時，將造成閃退
                if percentage > 0.0 {
                    textLabel.center = textPath.currentPoint
                    view.addSubview(textLabel)
                    percentageLabel.append(textLabel)

                }
                view.layer.addSublayer(percentageLayer)
                percentageLayers.append(percentageLayer)
                startDegree = endDegree
            }
        }

        myTableView.reloadData()
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 決定表格數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenseLabel.count
    }
    
    // 決定表格內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! ExpensetypeTableViewCell

        // expensepercentages
        let expensepercentages = [
            Double(displayexpense.personal),
            Double(displayexpense.dietary),
            Double(displayexpense.shopping),
            Double(displayexpense.traffic),
            Double(displayexpense.medical),
            Double(displayexpense.life)
        ]
        // incomepercentages
        let incomepercentages = [
            Double(displayincome.salary),
            Double(displayincome.interest),
            Double(displayincome.invest),
            Double(displayincome.rent),
            Double(displayincome.transaction),
            Double(displayincome.play)
        ]
        
        // 自訂的 cell
        
        switch changetypeSegmentedControl.selectedSegmentIndex {
        // 支出頁面
        case 0:
            cell.celltypeLabel.text = "\(expenseLabel[indexPath.row])"
            cell.cellmoneyLabel.text = "\(moneyString(Int(expensepercentages[indexPath.row])))"
            
            cell.circleview.backgroundColor = UIColor(cgColor: colors[indexPath.row])
            // 判斷 percentage 大於 0 , 才會新增第二 字串
            if (expensepercentages[indexPath.row] / expensepercentages.reduce(0, +)) > 0.0 {
                cell.percentageLabel.text = "\(String(format: "%.2f", (expensepercentages[indexPath.row] / expensepercentages.reduce(0, +) * 100))) %"
            }else {
                cell.percentageLabel.text = "0.00 %"
            }
        // 收入頁面
        default :
            cell.celltypeLabel.text = "\(incomeLabel[indexPath.row])"
            cell.cellmoneyLabel.text = "\(moneyString(Int(incomepercentages[indexPath.row])))"
            
            cell.circleview.backgroundColor = UIColor(cgColor: colors[indexPath.row])
            // 判斷 percentage 大於 0 , 才會新增第二 字串
            if (incomepercentages[indexPath.row] / incomepercentages.reduce(0, +)) > 0.0 {
                cell.percentageLabel.text = "\(String(format: "%.2f", (incomepercentages[indexPath.row] / incomepercentages.reduce(0, +) * 100))) %"
            }else {
                cell.percentageLabel.text = "0.00 %"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(assetLabel[indexPath.row])
//        print(totaldata["\(assetLabel[indexPath.row])"] ?? [])
//        performSegue(withIdentifier: "ty", sender: nil)
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
        incometotaldata[data.keys.first!] = data[data.keys.first!]
        
        updateUI()
    }
    
    
}
