//
//  RadarPermissionsHelper.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import CoreLocation
import Foundation

class RadarPermissionsHelper {
    
    func locationAuthorizationStatus() -> CLAuthorizationStatus {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        case .authorizedAlways:
            return .authorizedAlways
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        default:
            return .notDetermined
        }
    }
    
}
