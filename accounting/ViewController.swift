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
    // 支出總覽
    var myasset = Myasset(personal: 0, dietary: 0, shopping: 0, traffic: 0, medical: 0, life: 0)
    
    // 支出
    
    
    // 支出種類
    var assetLabel = ["個人", "飲食", "購物", "交通", "醫療", "生活"]
    
    // 所有支出總計
    var totaldata = [
        "個人": [Spending](),
        "飲食": [Spending](),
        "購物": [Spending](),
        "交通": [Spending](),
        "醫療": [Spending](),
        "生活": [Spending]()
    
    ]
    // 支出總額
    var amount = 0
    let totalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    // 角度
    let aDegree = CGFloat.pi / 180
    // 圖表顏色
    let colors = [
//        UIColor(red: 93/255, green: 95/255, blue: 238/255, alpha: 1).cgColor,
//        UIColor(red: 124/255, green: 138/255, blue: 1, alpha: 1).cgColor,
//        UIColor(red: 226/255, green: 137/255, blue: 242/255, alpha: 1).cgColor,
//        UIColor(red: 55/255, green: 57/255, blue: 143/255, alpha: 1).cgColor,
//        UIColor(red: 49/255, green: 63/255, blue: 69/255, alpha: 1).cgColor,
//        UIColor(red: 173/255, green: 82/255, blue: 186/255, alpha: 1).cgColor
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
        
        // tableview 高度設定為 view 的 2/5
        tableviewheightconstraint.constant = view.frame.height * 0.4
        
        // TableView
        myTableView.dataSource = self
        myTableView.delegate = self
        
        creatcirclePath()
        creatpercentageLabel()
//        print(myasset)
        
        let standardAppearance = UINavigationBarAppearance()

            // Title font color
            standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            // prevent Nav Bar color change on scroll view push behind NavBar
            standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor.systemGray6

            self.navigationController?.navigationBar.standardAppearance = standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        
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
            
            
            switch data.spendingtype {
            case "個人":
                myasset.personal += data.spending
                totaldata["個人"]?.insert(data, at: 0)
            case "飲食":
                myasset.dietary += data.spending
                totaldata["飲食"]?.insert(data, at: 0)
            case "購物":
                myasset.shopping += data.spending
                totaldata["購物"]?.insert(data, at: 0)
            case "交通":
                myasset.traffic += data.spending
                totaldata["交通"]?.insert(data, at: 0)
            case "醫療":
                myasset.medical += data.spending
                totaldata["醫療"]?.insert(data, at: 0)
            default:
                myasset.life += data.spending
                totaldata["生活"]?.insert(data, at: 0)
            }
            
            calculateall()
//            print(amount)
            
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
//                textLabel.backgroundColor = .yellow
                // 取得小數點前兩位
//                textLabel.text = "\(assetLabel[index]) \(String(format: "%.2f", (percentage / percentages.reduce(0, +) * 100 ))) %"
                textLabel.text = "\(assetLabel[index])"
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

                // 製作動畫
//                let animation = CABasicAnimation(keyPath: "strokeEnd")
//                var animationTime = 0.5
//                animation.fromValue = 0
//                animation.toValue = 1
//                animation.duration = 0.5
//
//                animationTime = animationTime * Double(index)
//                percentageLayer.add(animation, forKey: nil)
//
//                Timer.scheduledTimer(withTimeInterval: TimeInterval(animationTime), repeats: false) { _ in
//                    percentageLayer.add(animation, forKey: nil)
//                    self.view.layer.addSublayer(percentageLayer)
//                }


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
            // 資料整理
//            var renawal = [Spending]()
//            let new = data.values

            // 將新資料與總資料一起同步
            totaldata[data.keys.first!] = data[data.keys.first!]
            var new = 0
            for i in totaldata[data.keys.first ?? ""]! {
                new += i.spending
            }
            
            switch data.keys.first! {
            case "個人":
                myasset.personal = new
            case "飲食":
                myasset.dietary = new
            case "購物":
                myasset.shopping = new
            case "交通":
                myasset.traffic = new
            case "醫療":
                myasset.medical = new
            default:
                myasset.life = new
            }
            calculateall()
//            print(amount)
            
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
                textLabel.text = "\(assetLabel[index])"
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
            myTableView.reloadData()
            
        }
    }

    // 傳資料到 ListTableViewController
    @IBSegueAction func Senddata(_ coder: NSCoder) -> ListTableViewController? {
        // 判斷點選哪一個 row 來傳遞點選到的 data
        if let row = myTableView.indexPathForSelectedRow?.row {
            return ListTableViewController(coder: coder, list: totaldata["\(assetLabel[row])"] ?? [])
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
    
    // 點選表格的事件
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("get")
//        // 刪除前一個點選的 Layer
////        for i in percentageTable{
////            i.removeFromSuperlayer()
////        }
////        percentageTable.removeAll()
////        creatcirclePath()
//
//        let startDegree: CGFloat = 270
//
//        // 製作底色
//        let circlePath = UIBezierPath(arcCenter: view.center, radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + 360), clockwise: true)
//        let circleLayer = CAShapeLayer()
//        circleLayer.path = circlePath.cgPath
//        circleLayer.fillColor = UIColor.clear.cgColor
//        circleLayer.strokeColor = UIColor(red: 133/255, green: 92/255, blue: 248/255, alpha: 1).cgColor
////        circleLayer.strokeColor = UIColor.clear.cgColor
//        circleLayer.lineWidth = 40
//        view.layer.addSublayer(circleLayer)
//        percentageTable.append(circleLayer)
//
//
//        // 更新 圖表
//        let percentages = [
//            Double(myasset.personal),
//            Double(myasset.dietary),
//            Double(myasset.shopping),
//            Double(myasset.traffic),
//            Double(myasset.medical),
//            Double(myasset.life)
//        ]
//
//        let percentagePath = UIBezierPath(arcCenter: view.center, radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + 360), clockwise: true)
//
//        let percentageLayer = CAShapeLayer()
//        percentageLayer.path = percentagePath.cgPath
//        percentageLayer.fillColor = UIColor.clear.cgColor
//        percentageLayer.lineWidth = 40
//        percentageLayer.strokeColor = colors[indexPath.row]
//
//        view.layer.addSublayer(percentageLayer)
//        percentageTable.append(percentageLayer)
//
//        // 點選新的表格, 就更新一次 totalLabel
//        let newLabel = percentages[indexPath.row]
//        totalLabel.text = moneyString(Int(newLabel))
//        totalLabel.sizeToFit()
//        // 這邊必須再次設定 position，不然位置會跑掉
//        totalLabel.layer.position = view.center
//
//        // 新增點選表格時 percentage 動畫
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.fromValue = 0
//        animation.toValue = 1
//        animation.duration = 0.5
//        percentageLayer.add(animation, forKey: nil)
//
//        // 顯示點選圖層 3 秒後刪除
//        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [self] _ in
//            for i in self.percentageTable{
//                i.removeFromSuperlayer()
//            }
//            self.percentageTable.removeAll()
//            // 變回總額
//            self.totalLabel.text = moneyString(amount)
//            self.totalLabel.sizeToFit()
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(assetLabel[indexPath.row])
//        print(totaldata["\(assetLabel[indexPath.row])"] ?? [])
//        performSegue(withIdentifier: "ty", sender: nil)
    }
    
    
}
