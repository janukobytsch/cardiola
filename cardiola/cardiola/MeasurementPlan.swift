//
//  MeasurementPlan.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import RealmSwift

class MeasurementPlan: Object, PersistentModel {
    
    // MARK: PersistentModel
    
    dynamic var id: String = NSUUID().UUIDString
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: Container
    
    let entries = List<MeasurementPlanEntry>()
    
    var archivedEntries: [MeasurementPlanEntry] {
        var entries = self._collectEntries() { $0.isArchived }
        return entries.sort() { $0.data?.date!.compare(($1.data?.date!)!) == .OrderedDescending }
    }
    
    var pendingEntries: [MeasurementPlanEntry] {
        return self._collectEntries() { $0.isPending }
    }
    
    var activeEntries: [MeasurementPlanEntry] {
        return self._collectEntries() { $0.isActive }
    }
    
    func _collectEntries(filter: (MeasurementPlanEntry) -> Bool) -> [MeasurementPlanEntry] {
        let entries = self.entries.asArray().filter(filter)
        return (entries.count > 0) ? entries : [MeasurementPlanEntry]()
    }
    
    func prependEntry(entry: MeasurementPlanEntry) {
        entries.insert(entry, atIndex: 0)
    }
    
    func removeEntry(entry: MeasurementPlanEntry) {
        guard let index = self.entries.indexOf(entry) else {
            return
        }
        entries.removeAtIndex(index)
        entry.delete()
    }
    
    // MARK: Initialization
    
    convenience init(entries: [MeasurementPlanEntry]) {
        self.init()
        self.entries.appendContentsOf(entries)
    }
    
}