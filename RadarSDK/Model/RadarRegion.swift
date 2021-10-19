//
//  RadarRegion.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation


/// Represents a region.
///
/// See [Regions](https://radar.io/documentation/regions)
class RadarRegion: NSObject {
    
    /// The Radar ID of the region.
    private(set) var id = ""
    
    /// The name of the region.
    private(set) var name = ""
    
    /// The unique code for the region.
    private(set) var code = ""
    
    /// The type of the region.
    private(set) var type = ""
    
    /// The optional flag of the region.
    private(set) var flag: String?
    
    init(id: String, name: String, code: String, type: String, flag: String?) {
        self.id = id
        self.name = name
        self.code = code
        self.type = type
        self.flag = flag
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        let id = dict["_id"] as? String ?? "" //TODO: CONVERT _id to id
        let name = dict["name"] as? String ?? ""
        let code = dict["code"] as? String ?? ""
        let type = dict["type"] as? String ?? ""
        let flag = dict["flag"] as? String
        if !id.isEmpty && !name.isEmpty && !code.isEmpty && !type.isEmpty {
            self.init(id: id, name: name, code: code, type: type, flag: flag)
        } else {
            return nil
        }
    }
    
    func dictionaryValue() -> [AnyHashable : Any]? {
        var dict: [AnyHashable : Any] = [:]
        dict["_id"] = id
        dict["name"] = name
        dict["code"] = code
        dict["type"] = type
        if let flag = flag {
            dict["flag"] = flag
        }
        return dict
    }
    
}
