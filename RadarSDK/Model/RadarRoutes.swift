//
//  RadarRoutes.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 14.10.2021.
//

import Foundation

/// Represents routes from an origin to a destination.
///
/// See [Distance](https://radar.io/documentation/api#distance).
public class RadarRoutes {
    
    /// The geodesic distance between the origin and destination.
    private(set) var geodesic: RadarRouteDistance?
    
    /// The route by foot between the origin and destination. May be `nil` if mode not specified or route unavailable.
    private(set) var foot: RadarRoute?
    
    /// The route by bike between the origin and destination. May be `nil` if mode not specified or route unavailable.
    private(set) var bike: RadarRoute?
    
    /// The route by car between the origin and destination. May be `nil` if mode not specified or route unavailable.
    private(set) var car: RadarRoute?
    
    /// The route by truck between the origin and destination. May be `nil` if mode not specified or route unavailable.
    private(set) var truck: RadarRoute?
    
    /// The route by motorbike between the origin and destination. May be `nil` if mode not specified or route unavailable.
    private(set) var motorbike: RadarRoute?
    
    init(geodesic: RadarRouteDistance?, foot: RadarRoute?, bike: RadarRoute?, car: RadarRoute?, truck: RadarRoute?, motorbike: RadarRoute?) {
        self.geodesic = geodesic
        self.foot = foot
        self.bike = bike
        self.car = car
        self.truck = truck
        self.motorbike = motorbike
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        var geodesic: RadarRouteDistance?
        var foot: RadarRoute?
        var bike: RadarRoute?
        var car: RadarRoute?
        var truck: RadarRoute?
        var motorbike: RadarRoute? = nil
        if let geodesicDict = dict["geodesic"] as? [AnyHashable : Any], let distanceDict = geodesicDict["distance"] as? [AnyHashable : Any]  {
            geodesic = RadarRouteDistance(distanceDict)
        }
      
        if let footDict = dict["foot"] as? [AnyHashable : Any] {
            foot = RadarRoute(footDict)
        }
        
        if let bikeDict = dict["bike"] as? [AnyHashable : Any] {
            bike = RadarRoute(bikeDict)
        }
        
        if let carDict = dict["car"] as? [AnyHashable : Any] {
            car = RadarRoute(carDict)
        }
        
        if let truckDict = dict["truck"] as? [AnyHashable : Any] {
            truck = RadarRoute(truckDict)
        }
        
        if let motorbikeDict = dict["motorbike"] as? [AnyHashable : Any] {
            motorbike = RadarRoute(motorbikeDict)
        }

        self.init(geodesic: geodesic, foot: foot, bike: bike, car: car, truck: truck, motorbike: motorbike)
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["geodesic"] = geodesic?.dictionaryValue()
        dict["foot"] = foot?.dictionaryValue()
        dict["bike"] = bike?.dictionaryValue()
        dict["car"] = car?.dictionaryValue()
        dict["truck"] = truck?.dictionaryValue()
        dict["motorbike"] = motorbike?.dictionaryValue()
        return dict
    }
    
}
