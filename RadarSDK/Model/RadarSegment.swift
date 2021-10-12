//
//  RadarSegment.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 13.10.2021.
//

import Foundation

// Represents a user segment.
class RadarSegment {
    
    // The description of the segment.
    private(set) var description = ""
    
    //The external ID of the segment.
    private(set) var externalId = ""
    
    init(description: String, externalId: String) {
        self.description = description
        self.externalId = externalId
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        if let description = dict["description"] as? String, let externalId = dict["externalId"] as? String {
            self.init(description: description, externalId: externalId)
        } else {
            return nil
        }
    }
    
    static func array(forSegments segments: [RadarSegment]) -> [[AnyHashable : Any]] {
        var arr = [[AnyHashable : Any]]()
        for segment in segments {
            arr.append(segment.dictionaryValue())
        }
        return arr
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["description"] = description
        dict["externalId"] = externalId
        return dict
    }
    
}
