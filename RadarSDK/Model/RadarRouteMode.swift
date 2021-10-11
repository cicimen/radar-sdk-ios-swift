//
//  RadarRouteMode.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation

/// The travel modes for routes.
///
/// See the [Routing](https://radar.io/documentation/api#routing)
public struct RadarRouteMode : OptionSet {
    let rawValue: Int
    /// Foot
    static let foot = Self(rawValue: 1 << 0)
    /// Bike
    static let bike = Self(rawValue: 1 << 1)
    /// Car
    static let car = Self(rawValue: 1 << 2)
    /// Truck
    static let truck = Self(rawValue: 1 << 3)
    /// Motorbike
    static let motorbike = Self(rawValue: 1 << 4)
}
