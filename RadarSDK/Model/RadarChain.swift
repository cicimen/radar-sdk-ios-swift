//
//  RadarChain.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation

/// Represents the chain of a place.
///
/// See [Places](https://radar.io/documentation/places) .
class RadarChain {
    
    /// The unique ID of the chain. For a full list of chains, see [Chains](https://radar.io/documentation/places/chains).
    ///
    /// See [Chains](https://radar.io/documentation/places/chains) .
    private(set) var slug = ""
    
    /// The name of the chain. For a full list of chains, see [Chains](https://radar.io/documentation/places/chains).
    ///
    /// See [Chains](https://radar.io/documentation/places/chains) .
    private(set) var name = ""
    
    /// The external ID of the chain.
    private(set) var externalId: String?
    
    /// The optional set of custom key-value pairs for the chain.
    private(set) var metadata: [AnyHashable : Any]?
    
    init(slug: String, name: String, externalId: String?, metadata: [AnyHashable : Any]?) {
        self.slug = slug
        self.name = name
        self.externalId = externalId
        self.metadata = metadata
    }
    
    convenience init?(_ dict: [AnyHashable : Any]) {
        let slug = dict["slug"] as? String
        let name = dict["name"] as? String
        let externalId = dict["externalId"] as? String
        let metadata = dict["metadata"] as? [AnyHashable : Any]
        if let slug = slug, let name = name {
            self.init(slug: slug, name: name, externalId: externalId, metadata: metadata)
        } else {
            return nil
        }
    }
    
    class func array(forChains chains: [RadarChain]) -> [[AnyHashable : Any]]? {
        var arr = [[AnyHashable : Any]]()
        for chain in chains {
            arr.append(chain.dictionaryValue())
        }
        return arr
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["slug"] = slug
        dict["name"] = name
        dict["externalId"] = externalId
        dict["metadata"] = metadata
        return dict
    }
    
}
