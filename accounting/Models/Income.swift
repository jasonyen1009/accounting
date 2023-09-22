//
//  Income.swift
//  accounting
//
//  Created by Hong Cheng Yen on 2022/8/10.
//

import Foundation

struct Income: Codable {
    var date: Date
    var incometype: String
    var incomename: String
    var accounts: String
    var income: Int
    var note: String
    
    // 將資料另外寫檔儲存
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    // 編碼
    static func SaveIncome(_ mydata: [String: [Self]]) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(mydata)
        let url = documentsDirectory.appendingPathComponent("incomedata")
        try? data?.write(to: url)
    }
    // 解碼
    static func loadIncome() -> [String: [Income]]? {
        let decoder = JSONDecoder()
        let url = documentsDirectory.appendingPathComponent("incomedata")
        guard let data = try? Data(contentsOf: url) else { return nil}
        return try? decoder.decode([String: [Income]].self, from: data)
    }

}


