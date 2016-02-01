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
        return self._collectEntries() { $0.isArchived }
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
        entry.save()
    }
    
    func removeEntry(entry: MeasurementPlanEntry) {
        guard let index = self.entries.indexOf(entry) else {
            return
        }
        entries.removeAtIndex(index)
        // TODO: delete realm object
    }
    
    // MARK: Initialization
    
    convenience init(entries: [MeasurementPlanEntry]) {
        self.init()
        self.entries.appendContentsOf(entries)
    }

}