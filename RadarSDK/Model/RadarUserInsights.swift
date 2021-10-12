//
//  RadarUserInsights.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation

/// Represents the learned home, work, traveling and commuting state and locations of the current user.
///
/// See [Insights](https://radar.io/documentation/insights) .
class RadarUserInsights {
    
    /// The learned home location of the user. May be `nil` if not yet learned, or if Insights is turned off.
    private(set) var homeLocation: RadarUserInsightsLocation?
    
    /// The learned office location of the user. May be `nil` if not yet learned, or if Insights is turned off.
    private(set) var officeLocation: RadarUserInsightsLocation?
    
    /// The state of the user, based on learned home and office locations.
    private(set) var state: RadarUserInsightsState
    
    init(homeLocation: RadarUserInsightsLocation, officeLocation: RadarUserInsightsLocation, state: RadarUserInsightsState) {
        self.homeLocation = homeLocation
        self.officeLocation = officeLocation
        self.state = state
    }
    
    convenience init?(_ dict:[AnyHashable : Any]) {
        var homeLocation: RadarUserInsightsLocation?
        var officeLocation: RadarUserInsightsLocation?
        var state: RadarUserInsightsState?
        
        if let userInsightsLocationsArr = dict["locations"] as? [AnyHashable] {
            for locationObj in userInsightsLocationsArr {
                if let locationDict = locationObj as? [AnyHashable : Any] {
                    if let location = RadarUserInsightsLocation(locationDict) {
                        if location.type == .home {
                            homeLocation = location
                        } else if location.type == .office {
                            officeLocation = location
                        }
                    } else {
                        return nil
                    }
                }
            }
        }
        
        if let stateDic = dict["state"] as? [AnyHashable : Any] {
            state = RadarUserInsightsState(stateDic)
        }
        
        if let hl = homeLocation, let ol = officeLocation, let s = state {
            self.init(homeLocation: hl, officeLocation: ol, state: s)
        } else {
            return nil
        }
        
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        if let hl = homeLocation {
            dict["homeLocation"] = hl.dictionaryValue
        }
        if let ol = officeLocation {
            dict["homeLocation"] = ol.dictionaryValue //TODO: WHY WE PUT officeLocation IN homeLocation ????
        }
        dict["state"] = state.dictionaryValue
        return dict
    }
}
