//
//  Array+Remove.swift
//  cardiola
//
//  Created by Janusch Jacoby on 04/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation


extension Array {
    mutating func remove<T: AnyObject>(object: T) {
        var idx = -1
        for (index, element) in self.enumerate() {
            if object === element as? T {
                idx = index
            }
        }
        if idx != -1 {
            self.removeAtIndex(idx)
        }
    }
}