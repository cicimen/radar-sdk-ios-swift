//
//  RadarContext.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation
import CoreLocation

/// Represents the context for a location.
///
/// See [Context](https://radar.io/documentation/api#context).
class RadarContext {
    
    /// An array of the geofences for the location. May be empty if the location is not in any geofences.
    ///
    /// See [Geofences](https://radar.io/documentation/geofences).
    private(set) var geofences: [RadarGeofence] = []
    
    /// The place for the location. May be `nil` if the location is not at a place or if Places is not enabled.
    ///
    /// See [Places](https://radar.io/documentation/places).
    private(set) var place: RadarPlace?
    
    /// The country of the location. May be `nil` if country is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions).
    private(set) var country: RadarRegion?
    
    /// The state of the location. May be `nil` if state is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions).
    private(set) var state: RadarRegion?
    
    /// The designated market area (DMA) of the location. May be `nil` if DMA is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions).
    private(set) var dma: RadarRegion?
    
    /// The postal code of the location. May be `nil` if postal code is not available or if Regions is not enabled.
    ///
    /// See [Regions](https://radar.io/documentation/regions).
    private(set) var postalCode: RadarRegion?
    
    init(geofences: [RadarGeofence], place: RadarPlace?, country: RadarRegion?, state: RadarRegion?, dma: RadarRegion?, postalCode: RadarRegion?) {
        self.geofences = geofences
        self.place = place
        self.country = country
        self.state = state
        self.dma = dma
        self.postalCode = postalCode
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        var geofences: [RadarGeofence] = []
        var contextPlace: RadarPlace?
        var country: RadarRegion?
        var state: RadarRegion?
        var dma: RadarRegion?
        var postalCode: RadarRegion?
        
        if let contextGeofencesArr = dict["geofences"] as? [AnyHashable] {
            for contextGeofenceObj in contextGeofencesArr {
                if let contextGeofenceDict = contextGeofenceObj as? [AnyHashable: Any], let contextGeofence = RadarGeofence(contextGeofenceDict) {
                    geofences.append(contextGeofence)
                } else {
                    return nil
                }
            }
        }
        
        if let contextPlaceObj = dict["place"] as? [AnyHashable: Any] {
            contextPlace = RadarPlace(contextPlaceObj)
        }
        
        if let countryObj = dict["country"] as? [AnyHashable: Any] {
            country = RadarRegion(countryObj)
        }
        
        if let stateObj = dict["state"] as? [AnyHashable: Any] {
            state = RadarRegion(stateObj)
        }
        
        if let dmaObj = dict["dma"] as? [AnyHashable: Any] {
            dma = RadarRegion(dmaObj)
        }
        
        if let postalCodeObj = dict["postalCode"] as? [AnyHashable: Any] {
            postalCode = RadarRegion(postalCodeObj)
        }

        self.init(geofences: geofences, place: contextPlace, country: country, state: state, dma: dma, postalCode: postalCode)

    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        let geofencesArr = RadarGeofence.array(forGeofences: geofences)
        dict["geofences"] = geofencesArr
        if let place = place {
            dict["place"] = place.dictionaryValue()
        }
        if let country = country {
            dict["country"] = country.dictionaryValue()
        }
        if let state = state {
            dict["state"] = state.dictionaryValue()
        }
        if let dma = dma {
            dict["dma"] = dma.dictionaryValue()
        }
        if let postalCode = postalCode {
            dict["postalCode"] = postalCode.dictionaryValue()
        }
        return dict
    }
}
