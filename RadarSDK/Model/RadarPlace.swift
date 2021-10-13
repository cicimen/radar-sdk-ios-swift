//
//  RadarPlace.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 13.10.2021.
//

import Foundation
import CoreLocation

/// Represents a place.
///
/// See the [Places](https://radar.io/documentation/places)
class RadarPlace {
    
    /// The Radar ID of the place.
    private(set) var id = ""
    
    /// The name of the place.
    private(set) var name = ""
    
    /// The categories of the place. For a full list of categories, see [Categories](https://radar.io/documentation/places/categories).
    ///
    /// See [Categories](https://radar.io/documentation/places/categories).
    private(set) var categories: [String] = []
    
    /// The chain of the place, if known. May be `nil` for places without a chain. For a full list of chains, see [Chains](https://radar.io/documentation/places/chains).
    ///
    /// See [Chains](https://radar.io/documentation/places/chains).
    private(set) var chain: RadarChain?
    
    /// The location of the place.
    private(set) var location: RadarCoordinate
    
    /// The group for the place, if any. For a full list of groups, see [Groups](https://radar.io/documentation/places/groups).
    ///
    /// See [Groups](https://radar.io/documentation/places/groups).
    private(set) var group: String?
    
    /// The metadata for the place, if part of a group. For details of metadata fields see [Groups](https://radar.io/documentation/places/groups).
    ///
    /// See [Groups](https://radar.io/documentation/places/groups).
    private(set) var metadata: [AnyHashable : Any]?
    
    /// Returns a boolean indicating whether the place is part of the specified chain.
    ///
    /// - Parameters:
    ///     - slug: //TODO:
    ///
    /// - Returns: A boolean indicating whether the place is part of the specified chain.
    func isChain(_ slug: String) -> Bool {
        guard let chain = chain else {
            return false
        }
        return chain.slug.caseInsensitiveCompare(slug) == .orderedSame
    }
    
    /// Returns a boolean indicating whether the place has the specified category.
    ///
    /// - Parameters:
    ///     - category: //TODO:
    ///
    /// - Returns: A boolean indicating whether the place has the specified category.
    func hasCategory(_ category: String) -> Bool {
        for cat in categories {
            if cat.caseInsensitiveCompare(category) == .orderedSame {
                return true
            }
        }
        return false
    }
    
    init(id: String, name: String, categories: [String], chain: RadarChain?, location: RadarCoordinate, group: String, metadata: [AnyHashable : Any]?) {
        self.id = id
        self.name = name
        self.categories = categories
        self.chain = chain
        self.location = location
        self.group = group
        self.metadata = metadata
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        guard let id = dict["_id"] as? String else { //TODO: CONVERT _id to id
            return nil
        }
        guard let name = dict["name"] as? String else {
            return nil
        }
        let categories = dict["categories"] as? [String] ?? []
        var chain: RadarChain?
        var location = RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(0), CLLocationDegrees(0)))
        let group = dict["group"] as? String ?? ""
        let metadata = dict["metadata"] as? [AnyHashable : Any]
        if let chainDict = dict["chain"] as? [AnyHashable : Any] {
            chain = RadarChain(chainDict)
        }
        if let locationDict = dict["location"] as? [AnyHashable : Any] {
            if let locationCoordinatesArr = locationDict["coordinates"] as? [AnyHashable], locationCoordinatesArr.count == 2 {
                if let longitudeNumber = locationCoordinatesArr[0] as? NSNumber, let latitudeNumber = locationCoordinatesArr[1] as? NSNumber {
                    location = RadarCoordinate(coordinate: CLLocationCoordinate2DMake(CLLocationDegrees(latitudeNumber.floatValue), CLLocationDegrees(longitudeNumber.floatValue)))
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        self.init(id: id, name: name, categories: categories, chain: chain, location: location, group: group, metadata: metadata)
        
    }
    
    static func places(_ placesArr: [AnyHashable]) -> [RadarPlace]? {
        var arr: [RadarPlace] = []
        for placeObj in placesArr {
            if let placeDict = placeObj as? [AnyHashable : Any], let place = RadarPlace(placeDict) {
                arr.append(place)
            } else {
                return nil
            }
        }
        return arr
    }
    
    static func array(forPlaces places: [RadarPlace]) -> [[AnyHashable : Any]] {
        var arr = [[AnyHashable : Any]]()
        for place in places {
            arr.append(place.dictionaryValue())
        }
        return arr
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["_id"] = id //TODO: CONVERT _id to id
        dict["name"] = name
        dict["categories"] = categories
        if let chain = chain {
            dict["chain"] = chain.dictionaryValue
        }
        dict["group"] = group
        dict["metadata"] = metadata
        return dict
    }
}
