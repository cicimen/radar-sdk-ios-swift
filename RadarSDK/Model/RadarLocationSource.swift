//
//  RadarLocationSource.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation

/// The sources for location updates.
public enum RadarLocationSource : Int {
    /// Foreground
    case foregroundLocation
    /// Background
    case backgroundLocation
    /// Manual
    case manualLocation
    /// Visit arrival
    case visitArrival
    /// Visit departure
    case visitDeparture
    /// Geofence enter
    case geofenceEnter
    /// Geofence exit
    case geofenceExit
    /// Mock
    case mockLocation
    /// Beacon enter
    case beaconEnter
    /// Beacon exit
    case beaconExit
    /// Unknown
    case unknown
}
