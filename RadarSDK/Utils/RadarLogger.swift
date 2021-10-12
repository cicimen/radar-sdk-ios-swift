//
//  RadarLogger.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation

class RadarLogger {
    
    static let sharedInstance = RadarLogger()
    
    func log(level: RadarLogLevel, message: String?) {
        DispatchQueue.main.async(execute: {
            let logLevel = RadarSettings.logLevel()
            if logLevel.rawValue >= level.rawValue {
                let log = "\(message ?? "") | backgroundTimeRemaining = \(RadarUtils.backgroundTimeRemaining())"
                print("\(log)")
                RadarDelegateHolder.sharedInstance.didLog(message: log)
            }
        })
    }
}
