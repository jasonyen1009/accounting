//
//  AllNotification.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2023/1/14.
//

import Foundation

struct AllNotification {
    static let bankmessage = Notification.Name("updatebank")
    static let updateEXorINFromViewControlller = Notification.Name("updateEXorINFromViewControlller")
    static let updateEXorINFromCalenderViewController = Notification.Name("updateEXorINFromCalenderViewController")
    
    static let bankinfo = "bank"
    
}
