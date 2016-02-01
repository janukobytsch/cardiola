//
//  File.swift
//  cardiola
//
//  Created by Jakob Frick on 01/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import RealmSwift

extension List {
    func asArray() -> [T] {
        return self.map{ $0 }
    }
}

extension Results{
    func asArray() -> [T] {
        return self.map{ $0 }
    }
}