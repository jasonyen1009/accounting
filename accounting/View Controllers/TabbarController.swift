//
//  TabbarController.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2023/7/20.
//

import UIKit

class TabbarController: UITabBarController {
    
    var upperLineView: UIView!
    
    let spacing: CGFloat = 12

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            self.addTabbarIndicatorView(index: 0, isFirstTime: true)
        }


    }
    
    // 添加 TabBar 項目指示器的上方線條
    func addTabbarIndicatorView(index: Int, isFirstTime: Bool = false){
        // 獲取指定索引處 TabBar 項目的視圖
        guard let tabView = tabBar.items?[index].value(forKey: "view") as? UIView else {
            return
        }
        if !isFirstTime{
            upperLineView.removeFromSuperview()
        }
        // 創建上方線條視圖
        upperLineView = UIView(frame: CGRect(x: tabView.frame.minX + spacing, y: tabView.frame.minY + 0.1, width: tabView.frame.size.width - spacing * 2, height: 4))
        upperLineView.backgroundColor = UIColor(red: 55/255, green: 60/255, blue: 69/255, alpha: 1) // 設定線條視圖的顏色
//        upperLineView.backgroundColor = UIColor(red: 52/255, green: 73/255, blue: 102/255, alpha: 1) // 設定線條視圖的顏色
        tabBar.addSubview(upperLineView)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        tabBar.tintColor = nil // 取消 TabBar 項目的特定選中顏色
        item.image?.withRenderingMode(.alwaysTemplate) // 設定 TabBar 項目圖標渲染模式
    }

}

extension TabbarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        addTabbarIndicatorView(index: self.selectedIndex) // 選中 TabBar 項目時，添加指示器視圖
    }
}
