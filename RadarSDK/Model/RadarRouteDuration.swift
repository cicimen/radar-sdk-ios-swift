//
//  RadarRouteDuration.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 13.10.2021.
//

import Foundation

/// Represents the duration of a route.
class RadarRouteDuration {
    
    /// The duration in minutes.
    private(set) var value = 0.0
    
    /// A display string for the duration.
    private(set) var text = ""
    
    init(value: Double, text: String) {
        self.value = value
        self.text = text
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        var value: Double = 0
        guard let text = dict["text"] as? String else {
            return nil
        }
        if let valueNumber = dict["value"] as? NSNumber {
            value = valueNumber.doubleValue
        }
        self.init(value: value, text: text)
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["value"] = NSNumber(value: value)
        dict["text"] = text
        return dict
    }
}
