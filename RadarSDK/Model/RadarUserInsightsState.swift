//
//  RadarUserInsightsState.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation


/// Represents the learned home, work, traveling and commuting state of the current user.
///
/// See [Insights](https://radar.io/documentation/insights) .
class RadarUserInsightsState: NSObject {
    
    /// A boolean indicating whether the user is at home, based on learned home location.
    private(set) var home = false
    
    /// A boolean indicating whether the user is at the office, based on learned office location.
    private(set) var office = false
    
    /// A boolean indicating whether the user is traveling, based on learned home location.
    private(set) var traveling = false
    
    /// A boolean indicating whether the user is commuting, based on learned home location.
    private(set) var commuting = false
    
    init(home: Bool, office: Bool, traveling: Bool, commuting: Bool) {
        self.home = home
        self.office = office
        self.traveling = traveling
        self.commuting = commuting
    }
    
    convenience init(_ userInsightsStateDict:[AnyHashable : Any]) {
        let home = (userInsightsStateDict["home"] as? NSNumber)?.boolValue ?? false
        let office = (userInsightsStateDict["office"] as? NSNumber)?.boolValue ?? false
        let traveling = (userInsightsStateDict["traveling"] as? NSNumber)?.boolValue ?? false
        let commuting = (userInsightsStateDict["commuting"] as? NSNumber)?.boolValue ?? false
        self.init(home: home, office: office, traveling: traveling, commuting: commuting)
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["home"] = NSNumber(value: home)
        dict["office"] = NSNumber(value: office)
        dict["traveling"] = NSNumber(value: traveling)
        dict["commuting"] = NSNumber(value: commuting)
        return dict
    }
    
}
