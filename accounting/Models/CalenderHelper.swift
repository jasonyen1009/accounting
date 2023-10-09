//
//  CalenderHelper.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2022/12/17.
//

import Foundation
import UIKit


class CalendarHelper
{
    let calendar = Calendar.current
    
    let dateFormatter = DateFormatter()
    
    
    func plusMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    
    func minusMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    
    func monthString(date: Date) -> String
    {
//        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    
    func yearString(date: Date) -> String
    {
//        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func yearandmonth(date: Date) -> String
    {
        dateFormatter.dateFormat = "yyyy/MM"
        
        return dateFormatter.string(from: date)
    }
    
    
    func daysInMonth(date: Date) -> Int
    {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    
    func dayOfMonth(date: Date) -> Int
    {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    
    func firstOfMonth(date: Date) -> Date
    {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    
    func weekDay(date: Date) -> Int
    {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
    
    // 取得一週的日期的資料
    func getDatesForWeek(date: Date) -> [String]
    {
        var dates: [String] = []

        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: date)
        
        // 設置日期組件為該週的星期日
        dateComponents.weekday = 1
        
        // 取得該週的第一天（星期日）
        guard let firstDayOfWeek = calendar.date(from: dateComponents) else
        {
            return []
        }
        
        // 將日期加入到陣列
        for i in 0..<7
        {
            if let nextDate = calendar.date(byAdding: .day, value: i, to: firstDayOfWeek)
            {
                dates.append(dateFormatter.string(from: nextDate))
            }
        }
        
        return dates
    }
    
    // 取得一週的日期的資料 (沒有 year)
    func getDatesForWeekWithoutyear(date: Date) -> [String]
    {
        var dates: [String] = []

        dateFormatter.dateFormat = "MM/dd"
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: date)
        
        // 設置日期組件為該週的星期日
        dateComponents.weekday = 1
        
        // 取得該週的第一天（星期日）
        guard let firstDayOfWeek = calendar.date(from: dateComponents) else
        {
            return []
        }
        
        // 將日期加入到陣列
        for i in 0..<7
        {
            if let nextDate = calendar.date(byAdding: .day, value: i, to: firstDayOfWeek)
            {
                dates.append(dateFormatter.string(from: nextDate))
            }
        }
        
        return dates
    }
}

