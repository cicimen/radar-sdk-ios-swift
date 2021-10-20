//
//  RadarRouteMode.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation

/// The travel modes for routes.
///
/// See [Routing](https://radar.io/documentation/api#routing)
public struct RadarRouteMode : OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Foot
    public static let foot = RadarRouteMode(rawValue: 1 << 0)
    
    /// Bike
    public static let bike = RadarRouteMode(rawValue: 1 << 1)
    
    /// Car
    public static let car = RadarRouteMode(rawValue: 1 << 2)
    
    /// Truck
    public static let truck = RadarRouteMode(rawValue: 1 << 3)
    
    /// Motorbike
    public static let motorbike = RadarRouteMode(rawValue: 1 << 4)
    
}
