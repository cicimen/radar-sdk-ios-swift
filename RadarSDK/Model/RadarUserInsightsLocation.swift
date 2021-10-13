//
//  RadarUserInsightsLocation.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation
import CoreLocation

/// The types for learned locations.
enum RadarUserInsightsLocationType : Int {
    /// Unknown
    case unknown
    /// Home
    case home
    /// Office
    case office
}

/// The confidence levels for learned locations.
enum RadarUserInsightsLocationConfidence : Int {
    /// Unknown confidence
    case none = 0
    /// Low confidence
    case low = 1
    /// Medium confidence
    case medium = 2
    /// High confidence
    case high = 3
}

/// Represents a learned home or work location.
///
/// See [Insights](https://radar.io/documentation/insights) .
class RadarUserInsightsLocation {
    
    /// The type of the learned location.
    private(set) var type: RadarUserInsightsLocationType
    
    /// The learned location.
    private(set) var location: RadarCoordinate?
    
    /// The confidence level of the learned location.
    private(set) var confidence: RadarUserInsightsLocationConfidence
    
    /// The datetime when the learned location was updated.
    private(set) var updatedAt: Date
    
    /// The country of the learned location. May be `nil` if country is not available or if regions are not enabled.
    private(set) var country: RadarRegion?
    
    /// The state of the learned location. May be `nil` if state is not available or if regions are not enabled.
    private(set) var state: RadarRegion?
    
    /// The DMA of the learned location. May be `nil` if DMA is not available or if regions are not enabled.
    private(set) var dma: RadarRegion?
    
    /// The postal code of the learned location. May be `nil` if postal code is not available or if regions are not enabled.
    private(set) var postalCode: RadarRegion?
    
    init(type: RadarUserInsightsLocationType, location: RadarCoordinate?, confidence: RadarUserInsightsLocationConfidence, updatedAt: Date
         , country: RadarRegion?, state: RadarRegion?, dma: RadarRegion?, postalCode: RadarRegion?) {
        self.type = type
        self.location = location
        self.confidence = confidence
        self.updatedAt = updatedAt
        self.country = country
        self.state = state
        self.dma = dma
        self.postalCode = postalCode
    }
    
    convenience init?(_ dict:[AnyHashable : Any]) {
        var type: RadarUserInsightsLocationType = .unknown
        var location: RadarCoordinate?
        var confidence: RadarUserInsightsLocationConfidence = .none
        var updatedAt: Date?
        var country: RadarRegion?
        var state: RadarRegion?
        var dma: RadarRegion?
        var postalCode: RadarRegion?
        if let typeStr = dict["type"] as? String {
            if typeStr == "home" {
                type = .home
            } else if typeStr == "office" {
                type = .office
            }
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
        if let confidenceNumber = dict["confidence"] as? NSNumber {
            if confidenceNumber.intValue == 3 {
                confidence = .high
            } else if confidenceNumber.intValue == 2 {
                confidence = .medium
            } else if confidenceNumber.intValue == 1 {
                confidence = .low
            }
        }
        
        if let userInsightsLocationUpdatedAtStr = dict["updatedAt"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            updatedAt = dateFormatter.date(from: userInsightsLocationUpdatedAtStr)
        }
        
        if let countryDict = dict["country"] as? [AnyHashable : Any] {
            country = RadarRegion(countryDict)
        }
        
        if let stateDict = dict["state"] as? [AnyHashable : Any] {
            state = RadarRegion(stateDict)
        }
        
        if let dmaDict = dict["dma"] as? [AnyHashable : Any] {
            dma = RadarRegion(dmaDict)
        }
        
        if let postalCodeDict = dict["postalCode"] as? [AnyHashable : Any] {
            postalCode = RadarRegion(postalCodeDict)
        }
        
        if let updatedAt = updatedAt {
            self.init(type: type, location: location, confidence: confidence, updatedAt: updatedAt, country: country, state: state, dma: dma, postalCode: postalCode)
        } else {
            return nil
        }
    }
    
    class func string(for type: RadarUserInsightsLocationType) -> String? {
        switch type {
        case .home:
            return "home"
        case .office:
            return "office"
        default:
            return nil
        }
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["type"] = RadarUserInsightsLocation.string(for: self.type)
        if let location = location {
            dict["location"] = location.dictionaryValue
        }
        dict["confidence"] = NSNumber(value: self.confidence.rawValue)
        return dict
    }
}
