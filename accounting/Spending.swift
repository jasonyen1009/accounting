//
//  Spending.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/4/19.
//

import Foundation

struct Spending: Codable {
    var date: Date
    var spendingtype: String
    var spendingname: String
    var paytype: String
    var spending: Int
    var note: String
    // 編碼
    static func SaveSpending(_ mydata: [String: [Spending]]) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(mydata) else { return }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "spending")
    }
    // 解碼
    static func loadSpending() -> [String: [Spending]]? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: "spending") else { return nil}
        let decoder = JSONDecoder()
        return try? decoder.decode([String: [Spending]].self, from: data)
    }
}
