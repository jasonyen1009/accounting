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
    
    // date
    let now = Date()
    let dateformatter = DateFormatter()
    
    // 支出總覽 display
    var myasset = Myasset(personal: 0, dietary: 0, shopping: 0, traffic: 0, medical: 0, life: 0)
    
    // 支出種類
    var assetLabel = ["個人", "飲食", "購物", "交通", "醫療", "生活"]
    var assetLabel2 = ["個\n人", "飲\n食", "購\n物", "交\n通", "醫\n療", "生\n活"]
    
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
    
    var percentageLayers = [CALayer]()
    var percentageTable = [CALayer]()
    var percentageLabel = [UILabel]()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設置 dateformatter 格式
        dateformatter.dateFormat = "yyyyMM"
        
        // 取得儲存的資料
        if let spending = Spending.loadSpending() {
            self.totaldata = spending
        }

        // tableview 高度設定為 view 的 2/5
        tableviewheightconstraint.constant = view.frame.height * 0.4
        
        // TableView
        myTableView.dataSource = self
        myTableView.delegate = self
        
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
        totalLabel.layer.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100)
        
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
            let percentagePath = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100), radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * endDegree, clockwise: true)

            let percentageLayer = CAShapeLayer()
            percentageLayer.path = percentagePath.cgPath
            percentageLayer.fillColor = UIColor.clear.cgColor
            percentageLayer.lineWidth = 40
            percentageLayer.strokeColor = colors[index]

            // textlabel 座標
            let textPath = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100), radius: 140, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + (percentage / percentages.reduce(0, +)) * 180), clockwise: true)
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
            totalLabel.layer.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100)
            
            
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
                let percentagePath = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100), radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * endDegree, clockwise: true)

                let percentageLayer = CAShapeLayer()
                percentageLayer.path = percentagePath.cgPath
                percentageLayer.fillColor = UIColor.clear.cgColor
                percentageLayer.lineWidth = 40
                percentageLayer.strokeColor = colors[index]


                // textlabel 座標
                let textPath = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100), radius: 140, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + (percentage / percentages.reduce(0, +)) * 180), clockwise: true)
                // label 製作
                let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                textLabel.font = UIFont.systemFont(ofSize: 10)
                // assetLabel2 垂直顯示
                textLabel.text = "\(assetLabel[index])"
                textLabel.numberOfLines = 0
                textLabel.sizeToFit()
//                textLabel.center = textPath.currentPoint
//                view.addSubview(textLabel)
//                percentageLabel.append(textLabel)

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
            // 更新表格
            myTableView.reloadData()
        }
    }
    
    // 點選 Black 返回
    @IBAction func unwindToBlack(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        if let source = unwindSegue.source as? ListTableViewController,
           let data = source.renewaldata {
//            print("data \(data)")

            // 將新資料與 totaldata 總資料一起同步
            totaldata[data.keys.first!] = data[data.keys.first!]
            
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
            totalLabel.layer.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100)
            
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
                let percentagePath = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100), radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * endDegree, clockwise: true)

                let percentageLayer = CAShapeLayer()
                percentageLayer.path = percentagePath.cgPath
                percentageLayer.fillColor = UIColor.clear.cgColor
                percentageLayer.lineWidth = 40
                percentageLayer.strokeColor = colors[index]

                // textlabel 座標
                let textPath = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100), radius: 140, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + (percentage / percentages.reduce(0, +)) * 180), clockwise: true)
                
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
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100), radius: 90, startAngle: aDegree * 270, endAngle: aDegree * (270 + 360), clockwise: true)
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
        totalLabel.layer.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - 100)
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
