//
//  AllNotification.swift
//  accounting
//
//  Created by Yen Hung Cheng on 2023/1/14.
//

import Foundation

struct AllNotification {
    static let bankmessage = Notification.Name("updatebank")
    static let updateEXorIN = Notification.Name("updateEXorIN")
    
    static let bankinfo = "bank"
    static let updateinfo = "EXorIN"
}
