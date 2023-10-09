//
//  HomeViewController.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/8/2.
//

import UIKit

class HomeViewController: UIViewController {

    var homedata: Any?
    var value = false
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var segmentedcontrol: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 禁止頁面下拉
        self.isModalInPresentation = true
        
        // scrollview delegate
        scrollview.delegate = self
        
        // 隱藏 scro;;view 底下的移動條
        scrollview.showsHorizontalScrollIndicator = false

    }
    
    @IBAction func ChangePage(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            
            value = true
            scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
        default:
            
            value = true
            scrollview.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: true)

        }
    }
    
    
    @IBSegueAction func ExpenseSegueAction(_ coder: NSCoder) -> AddExpenseTableViewController? {
        let controller = AddExpenseTableViewController(coder: coder)
        controller?.delegate = self
        return controller
    }
    
    @IBSegueAction func IncomeSegueAction(_ coder: NSCoder) -> AddIncomeTableViewController? {
        let controller = AddIncomeTableViewController(coder: coder)
        controller?.delegate = self
        return controller
    }
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if value == false {
            if scrollview.contentOffset.x > view.frame.width / 2 {
                segmentedcontrol.selectedSegmentIndex = 1
            }else {
                segmentedcontrol.selectedSegmentIndex = 0
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        value = false

    }
}

extension HomeViewController: AddExpenseTableViewControllerDelegate {
    
    func addExpenseTableViewController(_ controller: AddExpenseTableViewController, didEdit data: Expense) {
        homedata = data
        print(homedata!)
    }
    
}

extension HomeViewController: AddIncomeTableViewControllerDelegate {
    
    func addIncomeTableViewController(_ controller: AddIncomeTableViewController, didEdit data: Income) {
        homedata = data
        print(homedata!)
    }
    
}
