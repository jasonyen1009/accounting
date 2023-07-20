//
//  TabBarWithCorners.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2023/7/20.
//

import UIKit

@IBDesignable // 用於標記自定義視圖類別，以便在 Interface Builder 中進行即時的設計預覽
class TabBarWithCorners: UITabBar {
    
    @IBInspectable var color: UIColor? // 可在 Interface Builder 中設定的屬性，用於設定 Tab Bar 的背景顏色
    @IBInspectable var radii: CGFloat = 18 // 可在 Interface Builder 中設定的屬性，用於設定 Tab Bar 圓角半徑
    
    private var shapeLayer: CALayer?
    
    override func draw(_ rect: CGRect) {
        addShape() // 在 Tab Bar 上添加自定義的形狀圖層
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = createPath() // 創建 Tab Bar 的形狀路徑
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor // 設定 Tab Bar 的填充顏色，如果 color 屬性為空則使用白色
        shapeLayer.lineWidth = 0
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: -2);
        shapeLayer.shadowOpacity = 0.21
        shapeLayer.shadowRadius = 8
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath // 設定 Tab Bar 的陰影效果
        
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer) // 替換舊的形狀圖層
        } else {
            layer.insertSublayer(shapeLayer, at: 0) // 添加形狀圖層到 Tab Bar 的最底層
        }
        
        self.shapeLayer = shapeLayer
    }
    
    private func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds, // Tab Bar 的範圍
            byRoundingCorners: [.topLeft, .topRight], // 設定 Tab Bar 左上和右上兩個角為圓角
            cornerRadii: CGSize(width: radii, height: 0.0)) // 設定圓角的半徑
        
        return path.cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
        var tabFrame = self.frame
        let bottomSafeAreaHeight: CGFloat

        if #available(iOS 15.0, *) {
            bottomSafeAreaHeight = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first?
                .safeAreaInsets.bottom ?? 0
        } else {
            bottomSafeAreaHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        }

        tabFrame.size.height = 50 + bottomSafeAreaHeight
        tabFrame.origin.y = self.frame.origin.y + self.frame.height - 50 - bottomSafeAreaHeight
        self.layer.cornerRadius = 18 // 設定 Tab Bar 的圓角半徑
        self.frame = tabFrame
        self.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -5.0) }) // 調整 Tab Bar 項目的標題位置
    }
}
