//
//  UpdateListener.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

protocol UpdateListener: class {
    func update()
}

protocol UpdateProvider: class {
    func addUpdateListener(listener: UpdateListener)
}