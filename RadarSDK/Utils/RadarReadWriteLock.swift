//
//  RadarReadWriteLock.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 21.10.2021.
//

import Foundation

class RadarReadWriteLock {
    let concurentQueue: DispatchQueue

    init(label: String) {
        self.concurentQueue = DispatchQueue(label: label, attributes: .concurrent)
    }

    func read(closure: () -> Void) {
        self.concurentQueue.sync {
            closure()
        }
    }
    func write(closure: () -> Void) {
        self.concurentQueue.sync(flags: .barrier, execute: {
            closure()
        })
    }
}

