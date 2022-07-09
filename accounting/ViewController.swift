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
    var myasset = Myasset(personal: 0, dietary: 0, shopping: 0, traffic: 0, medical: 0, life: 0)
    
    // 支出種類
    var assetLabel = ["個人", "飲食", "購物", "交通", "醫療", "生活"]
    var assetLabel2 = ["個\n人", "飲\n食", "購\n物", "交\n通", "醫\n療", "生\n活"]
    
    // years, months
    var years = ["2021", "2022", "2023", "2024", "2025", "2026"]
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    // 所有支出總計
    var totaldata = [
        "個人": [Spending](),
        "飲食": [Spending](),
        "購物": [Spending](),
        "交通": [Spending](),
        "醫療": [Spending](),
        "生活": [Spending]()
    
    ] {
        didSet {
            Spending.SaveSpending(totaldata)
        }
    }
    // 支出總額
    var amount = 0
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
    
    // Pickerview
    let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
    
    var percentageLayers = [CALayer]()
    var percentageTable = [CALayer]()
    var percentageLabel = [UILabel]()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定圖的位置設置
        position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100)
        
        // 設置 dateformatter 格式
        dateformatter.dateFormat = "yyyy,MMM"
        
        // 將 Button 日期設為 當前年月份
        changeDateButton.setTitle("\(dateformatter.string(from: now))", for: .normal)
        
        // 取得儲存的資料
        if let spending = Spending.loadSpending() {
            self.totaldata = spending
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
//        let sourceViewController = unwindSegue.source
        if let source = unwindSegue.source as? NewTableViewController ,
           let data = source.mydata {
//            print(data)
            // 判斷為哪種消費, 並新增至該消費中
            switch data.spendingtype {
            case "個人":
                totaldata["個人"]?.insert(data, at: 0)
            case "飲食":
                totaldata["飲食"]?.insert(data, at: 0)
            case "購物":
                totaldata["購物"]?.insert(data, at: 0)
            case "交通":
                totaldata["交通"]?.insert(data, at: 0)
            case "醫療":
                totaldata["醫療"]?.insert(data, at: 0)
            default:
                totaldata["生活"]?.insert(data, at: 0)
            }
            
            // 畫面更新
            updateUI()
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ListTableViewController {
            // 成為 ListTableViewControllerDelegate delegate
            controller.delegate = self
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
            return ListTableViewController(coder: coder, list: totaldata["\(assetLabel[row])"] ?? [], date: now)
        }else {
            return nil
        }
    }
    
    // 計算總和
    func calculateall() {
        var total = 0
        for label in assetLabel {
            for value in totaldata["\(label)"] ?? [] {
                total += value.spending
            }
        }
        amount = total
    }
    
    // 頁面顯示總和
    func calculateDisplay() {
        var total = 0
        total += myasset.personal
        total += myasset.dietary
        total += myasset.shopping
        total += myasset.traffic
        total += myasset.medical
        total += myasset.life
        amount = total
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
    
    // 計算各個消費 spending 總和
    // 用於所有畫面更新
    func calculate(_ spendingtype: String, date: Date) -> Int {
        var spending = 0
        for i in totaldata[spendingtype]! {
            // 判斷是否為 本月的月份
            if dateformatter.string(from: i.date) == dateformatter.string(from: date) {
                spending += i.spending
            }
        }
        return spending
    }
    
    // 所有畫面資料更新
    func updateUI() {
        // 畫面更新
        myasset.personal = calculate("個人",date: now)
        myasset.dietary = calculate("飲食",date: now)
        myasset.shopping = calculate("購物",date: now)
        myasset.traffic = calculate("交通",date: now)
        myasset.medical = calculate("醫療",date: now)
        myasset.life = calculate("生活",date: now)
        
        calculateDisplay()
        
        totalLabel.text = moneyString(amount)
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
        if amount == 0 {
            creatcirclePath()
        }
                    
        // 更新 圖表
        var startDegree: CGFloat = 270
        let percentages = [
            Double(myasset.personal),
            Double(myasset.dietary),
            Double(myasset.shopping),
            Double(myasset.traffic),
            Double(myasset.medical),
            Double(myasset.life)
        ]
        
        // 繪製 各項比例圖表及文字
        for (index, percentage) in percentages.enumerated() {
            // percentages.reduce(0, +) 取得 percentages 總數
            let endDegree = startDegree + (percentage / percentages.reduce(0, +)) * 360
            let percentagePath = UIBezierPath(arcCenter: position, radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * endDegree, clockwise: true)

            let percentageLayer = CAShapeLayer()
            percentageLayer.path = percentagePath.cgPath
            percentageLayer.fillColor = UIColor.clear.cgColor
            percentageLayer.lineWidth = 40
            percentageLayer.strokeColor = colors[index]

            // textlabel 座標
            let textPath = UIBezierPath(arcCenter: position, radius: 125, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + (percentage / percentages.reduce(0, +)) * 180), clockwise: true)
            
            // label 製作
            let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            textLabel.font = UIFont.systemFont(ofSize: 10)
            
            // assetLabel2 垂直顯示
            textLabel.text = "\(assetLabel[index])"
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
        myTableView.reloadData()
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 決定表格數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assetLabel.count
    }
    
    // 決定表格內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! SpendingtypeTableViewCell

        let percentages = [
            Double(myasset.personal),
            Double(myasset.dietary),
            Double(myasset.shopping),
            Double(myasset.traffic),
            Double(myasset.medical),
            Double(myasset.life)
        ]
        
        // 自訂的 cell
        cell.spendingtypeLabel.text = "\(assetLabel[indexPath.row])"
        cell.spendingLabel.text = "\(moneyString(Int(percentages[indexPath.row])))"
        cell.circleview.backgroundColor = UIColor(cgColor: colors[indexPath.row])
        // 判斷 percentage 大於 0 , 才會新增第二 字串
        if (percentages[indexPath.row] / percentages.reduce(0, +)) > 0.0 {
            cell.percentageLabel.text = "\(String(format: "%.2f", (percentages[indexPath.row] / percentages.reduce(0, +) * 100))) %"
        }else {
            cell.percentageLabel.text = "0.00 %"
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
extension ViewController: ListTableViewControllerDelegate {
    
    func listTableViewController(_ controller: ListTableViewController, didEdit data: [String : [Spending]]) {
        
        // 將新資料與 totaldata 總資料一起同步
        totaldata[data.keys.first!] = data[data.keys.first!]
        // 畫面更新
        updateUI()
    }
    
    
    
}
