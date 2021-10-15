//
//  RadarUtils.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 11.10.2021.
//

import Foundation
import CoreLocation
import UIKit
import AdSupport
import AppTrackingTransparency

class RadarUtils {
    
    //TODO: CHECK AGAIN
    static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let size = MemoryLayout<CChar>.size
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: size) {
                String(cString: UnsafePointer<CChar>($0))
            }
        }
        if let model = String(validatingUTF8: modelCode) {
            return model
        }
        return ""
    }
    
    static func deviceOS() -> String {
        return UIDevice.current.systemVersion
    }
    
    static func country() -> String? {
        return (NSLocale.current as NSLocale).countryCode
    }
    
    static func timeZoneOffset() -> NSNumber? {
        return NSNumber(value: Int(NSTimeZone.local.secondsFromGMT()))
    }
    
    static func sdkVersion() -> String {
        return "3.2.0"
    }
    
    static func adId() -> String {
        if #available(iOS 14, *), ATTrackingManager.trackingAuthorizationStatus == .authorized {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return "OptedOut"
            }
        }
    }
    
    static func deviceId() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    static func deviceType() -> String {
        return "iOS"
    }
    
    static func deviceMake() -> String {
        return "Apple"
    }
    
    static func locationBackgroundMode() -> Bool {
        let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [AnyHashable]
        return backgroundModes != nil && backgroundModes?.contains("location") ?? false
    }
    
    static func locationAuthorization() -> String {
        //TODO: if #available(iOS 14.0, *)
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .authorizedWhenInUse:
            return "GRANTED_FOREGROUND"
        case .authorizedAlways:
            return "GRANTED_BACKGROUND"
        case .denied:
            return "DENIED"
        case .restricted:
            return "DENIED"
        default:
            return "NOT_DETERMINED"
        }
    }
    
    static func locationAccuracyAuthorization() -> String {
        if #available(iOS 14.0, *) {
            let accuracyAuthorization = CLLocationManager().accuracyAuthorization
            switch accuracyAuthorization {
            case .reducedAccuracy:
                return "REDUCED"
            default:
                return "FULL"
            }
        } else {
            return "FULL"
        }
    }
    
    static func foreground() -> Bool {
        return UIApplication.shared.applicationState != .background
    }
    
    static func backgroundTimeRemaining() -> TimeInterval {
        let backgroundTimeRemaining = UIApplication.shared.backgroundTimeRemaining
        return TimeInterval((backgroundTimeRemaining == .greatestFiniteMagnitude) ? 180 : backgroundTimeRemaining)
    }
    
    //TODO: CHECK AGAIN
    static func location(forDictionary dict: [AnyHashable : Any]) -> CLLocation? {
        var location: CLLocation? = nil
        if let latitudeValue = (dict["latitude"] as? NSNumber)?.doubleValue
            , let longitudeValue = (dict["longitude"] as? NSNumber)?.doubleValue {
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitudeValue), CLLocationDegrees(longitudeValue))
            if let aDict = dict["timestamp"] as? Date {
                location = CLLocation(
                    coordinate: coordinate,
                    altitude: CLLocationDistance((dict["altitude"] as? NSNumber)?.doubleValue ?? 0.0),
                    horizontalAccuracy: CLLocationAccuracy((dict["horizontalAccuracy"] as? NSNumber)?.doubleValue ?? 0.0),
                    verticalAccuracy: CLLocationAccuracy((dict["verticalAccuracy"] as? NSNumber)?.doubleValue ?? 0.0),
                    timestamp: aDict)
            }
        }
        return location
    }
    
    static func dictionary(for location: CLLocation) -> [AnyHashable : Any] {
        return [
            "latitude": NSNumber(value: location.coordinate.latitude),
            "longitude": NSNumber(value: location.coordinate.longitude),
            "horizontalAccuracy": NSNumber(value: location.horizontalAccuracy),
            "verticalAccuracy": NSNumber(value: location.verticalAccuracy),
            "timestamp": location.timestamp
        ]
    }
    
    static func validLocation(_ location: CLLocation) -> Bool {
        let latitudeValid = location.coordinate.latitude > -90 && location.coordinate.latitude < 90
        let longitudeValid = location.coordinate.longitude > -180 && location.coordinate.latitude < 180
        let horizontalAccuracyValid = location.horizontalAccuracy > 0
        return latitudeValid && longitudeValid && horizontalAccuracyValid
    }
    
    // MARK: - threading
    
    static func run(onMainThread block: @escaping () -> ()) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: {
                block()
            })
        }
        return
    }
}
