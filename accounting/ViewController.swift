//
//  ViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/4/19.
//

import UIKit

class ViewController: UIViewController {

    // 支出總覽
    var myasset = Spending(personal: 0, dietary: 0, shopping: 0, traffic: 0, medical: 0, life: 0)
    // 支出種類
    var assetLabel = ["個人", "飲食", "購物", "交通", "醫療", "生活"]
    // 支出總額
    var amount = 0
    let totalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    // 角度
    let aDegree = CGFloat.pi / 180
    // 圖表顏色
    let colors = [
        UIColor(red: 93/255, green: 95/255, blue: 238/255, alpha: 1).cgColor,
        UIColor(red: 124/255, green: 138/255, blue: 1, alpha: 1).cgColor,
        UIColor(red: 226/255, green: 137/255, blue: 242/255, alpha: 1).cgColor,
        UIColor(red: 55/255, green: 57/255, blue: 143/255, alpha: 1).cgColor,
        UIColor(red: 49/255, green: 63/255, blue: 69/255, alpha: 1).cgColor,
        UIColor(red: 173/255, green: 82/255, blue: 186/255, alpha: 1).cgColor
    ]
    
    
    var percentageLayers = [CALayer]()
    var percentageLabel = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creatcirclePath()
        
        creatpercentageLabel()
//        print(myasset)

    }
    
    // 點選 cancel 返回
    @IBAction func unwindTopcancel(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // 點選 Done 返回
    @IBAction func unwindToDone(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        if let source = unwindSegue.source as? accountingTableViewController {
            // 編輯頁面讀取 editaccount
            myasset = source.editaccount
            amount = myasset.life + myasset.medical + myasset.dietary + myasset.shopping + myasset.personal + myasset.traffic
            
            totalLabel.text = moneyString(amount)
            totalLabel.sizeToFit()
            // 這邊必須再次設定 position，不然位置會跑掉
            totalLabel.layer.position = view.center
            
            
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
                let percentagePath = UIBezierPath(arcCenter: view.center, radius: 90, startAngle: aDegree * startDegree, endAngle: aDegree * endDegree, clockwise: true)
                
                let percentageLayer = CAShapeLayer()
                percentageLayer.path = percentagePath.cgPath
                percentageLayer.fillColor = UIColor.clear.cgColor
                percentageLayer.lineWidth = 40
                percentageLayer.strokeColor = colors[index]

                
                // textlabel 座標
                let textPath = UIBezierPath(arcCenter: view.center, radius: 140, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + (percentage / percentages.reduce(0, +)) * 180), clockwise: true)
                // label 製作
                let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                textLabel.font = UIFont.systemFont(ofSize: 10)
//                textLabel.backgroundColor = .yellow
                // 取得小數點前兩位
                textLabel.text = "\(assetLabel[index]) \(String(format: "%.2f", (percentage / percentages.reduce(0, +) * 100 ))) %"
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
        }
    }
    
    // 最底層的 percentage
    func creatcirclePath() {
        let circlePath = UIBezierPath(arcCenter: view.center, radius: 90, startAngle: aDegree * 270, endAngle: aDegree * (270 + 360), clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(red: 133/255, green: 92/255, blue: 248/255, alpha: 1).cgColor
        circleLayer.lineWidth = 40
        view.layer.addSublayer(circleLayer)
    }
    
    // 初始金額
    func creatpercentageLabel() {
        totalLabel.text = "0"
        totalLabel.font = UIFont.systemFont(ofSize: 20)
        totalLabel.sizeToFit()
        totalLabel.layer.position = view.center
        view.addSubview(totalLabel)
    }
    
    // 收鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // 資料傳回前新增頁面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowNavigation01" {
            if let destVC = segue.destination as? UINavigationController,
               let targetController = destVC.topViewController as? accountingTableViewController {
                targetController.editaccount = myasset
                }
        }
    }
    
    // 數字轉為金錢格式文字
    func moneyString(_ money: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.numberStyle = .currencyISOCode
        return formatter.string(from: NSNumber(value: money)) ?? ""
    }

}

