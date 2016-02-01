//
//  ObjectSave.swift
//  cardiola
//
//  Created by Jakob Frick on 01/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//
import RealmSwift

extension Object {
    
    func save() {
        try! realm?.write {
            if self.dynamicType.primaryKey() != nil {
                realm?.create(self.dynamicType, value: self, update: true)
            }
        }
    }
}