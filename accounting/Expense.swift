//
//  Expense.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/4/19.
//

import Foundation

struct Expense: Codable {
    var date: Date
    var expensetype: String
    var expensename: String
    var paytype: String
    var expense: Int
    var note: String
    // 將資料另外寫檔儲存
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    // 編碼
    static func SaveExpense(_ mydata: [String: [Self]]) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(mydata)
        let url = documentsDirectory.appendingPathComponent("mydata")
        try? data?.write(to: url)
    }
    // 解碼
    static func loadExpense() -> [String: [Expense]]? {
        let decoder = JSONDecoder()
        let url = documentsDirectory.appendingPathComponent("mydata")
        guard let data = try? Data(contentsOf: url) else { return nil}
        return try? decoder.decode([String: [Expense]].self, from: data)
    }
}
