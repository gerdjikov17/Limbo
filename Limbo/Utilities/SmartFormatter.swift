//
//  SmartFormatter.swift
//  Limbo
//
//  Created by A-Team User on 21.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class SmartFormatter: NSObject {
    static func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        if date.timeIntervalSinceNow >= -86000 { // < one day
            formatter.dateFormat = "HH:mm"
        }
        else if date.timeIntervalSinceNow <= -86000*7 { // > one week
            formatter.dateFormat = "E, d MMM yyyy HH:mm"
        }
        else if date.timeIntervalSinceNow <= -86000 { // > one day
            formatter.dateFormat = "E, HH:mm"
        }
        return formatter.string(from: date)
        
    }
}
