//
//  PersistentModel.swift
//  cardiola
//
//  Created by Jakob Frick on 01/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

protocol PersistentModel {
    var id: String { get }
    
    func save()
    static func primaryKey() -> String?
}

