//
//  RadarBeaconManager.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 19.10.2021.
//

import Foundation
import CoreLocation

class RadarBeaconManager: CLLocationManagerDelegate {
    var locationManager: CLLocationManager
    var permissionsHelper: RadarPermissionsHelper
    
    private var started = false
    private var completionHandlers: [RadarBeaconCompletionHandler] = []
    private var nearbyBeaconIdentifers: Set<String> = []
    private var failedBeaconIdentifiers: Set<String> = []
    private var beacons: [RadarBeacon] = []
    
    static let sharedInstance = RadarBeaconManager()
    
    
    
    func rangeBeacons(_ beacons: [RadarBeacon], completionHandler: RadarBeaconCompletionHandler) {
    }
}

