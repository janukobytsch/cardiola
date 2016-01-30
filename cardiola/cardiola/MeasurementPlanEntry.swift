//
//  MeasurementPlanEntry.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

class MeasurementPlanEntry: NSObject {
    
    var id: Int?
    var dueDate: NSDate?
    var isMandatory: Bool?
    
    var formattedDate: String {
//        let formatter = NSDateFormatter()
//        formatter.locale = NSLocale(localeIdentifier: "de_DE")
        return self._formatDate(NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    var formattedTime: String {
        return self._formatDate(NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.FullStyle)
    }
    
    init(dueDate: NSDate, isMandatory: Bool) {
        super.init()
        self.dueDate = dueDate
        self.isMandatory = isMandatory
    }
    
    convenience init(dueDate: NSDate) {
        self.init(dueDate: dueDate, isMandatory: true)
    }
    
    // MARK: Formatting
    
    private func _formatDate(dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
        guard let dueDate = self.dueDate else {
            return ""
        }
        return NSDateFormatter.localizedStringFromDate(dueDate, dateStyle: dateStyle,
            timeStyle: timeStyle)

    }
}