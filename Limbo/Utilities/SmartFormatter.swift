//
//  SmartFormatter.swift
//  Limbo
//
//  Created by A-Team User on 21.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class SmartFormatter: DateFormatter {
    
    static let instance = SmartFormatter()
    
    func formatDate(date: Date) -> String {
        if date.timeIntervalSinceNow >= -86000 { // < one day
            self.dateFormat = "HH:mm"
        } else if date.timeIntervalSinceNow <= -86000*7 { // > one week
            self.dateFormat = "E, d MMM yyyy HH:mm"
        } else if date.timeIntervalSinceNow <= -86000 { // > one day
            self.dateFormat = "E, HH:mm"
        }
        return self.string(from: date)
        
    }
}
