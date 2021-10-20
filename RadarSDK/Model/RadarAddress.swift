//
//  RadarAddress.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 12.10.2021.
//

import Foundation
import CoreLocation

/// The confidence levels for geocoding results.
enum RadarAddressConfidence : Int {
    /// Unknown
    case none = 0
    /// Exact
    case exact = 1
    /// Interpolated
    case interpolated = 2
    /// Fallback
    case fallback = 3
}

/// Represents an address.
///
/// See [Geocoding](https://radar.io/documentation/api#geocoding) .
public class RadarAddress {
    
    //The location coordinate of the address.
    private(set) var coordinate: CLLocationCoordinate2D
    
    //The formatted string representation of the address.
    private(set) var formattedAddress: String?
    
    //The name of the country of the address.
    private(set) var country: String?
    
    //The unique code of the country of the address.
    private(set) var countryCode: String?
    
    //The flag of the country of the address.
    private(set) var countryFlag: String?
    
    //The name of the DMA of the address.
    private(set) var dma: String?
    
    //The unique code of the DMA of the address.
    private(set) var dmaCode: String?
    
    //The name of the state of the address.
    private(set) var state: String?
    
    //The unique code of the state of the address.
    private(set) var stateCode: String?
    
    //The postal code of the address.
    private(set) var postalCode: String?
    
    //The city of the address.
    private(set) var city: String?
    
    //The borough of the address.
    private(set) var borough: String?
    
    //The county of the address.
    private(set) var county: String?
    
    //The neighborhood of the address.
    private(set) var neighborhood: String?
    
    //The street number of the address.
    private(set) var number: String?
    
    //The label of the address.
    private(set) var addressLabel: String?
    
    //The label of the place.
    private(set) var placeLabel: String?
    
    //The confidence level of the geocoding result.
    var confidence: RadarAddressConfidence
    
    init(coordinate: CLLocationCoordinate2D, formattedAddress: String?, country: String?, countryCode: String?, countryFlag: String?, dma: String?, dmaCode: String?, state: String?, stateCode: String?, postalCode: String?, city: String?, borough: String?, county: String?, neighborhood: String?, number: String?, addressLabel: String?, placeLabel: String?, confidence: RadarAddressConfidence) {
        self.coordinate = coordinate
        self.formattedAddress = formattedAddress
        self.country = country
        self.countryCode = countryCode
        self.countryFlag = countryFlag
        self.dma = dma
        self.dmaCode = dmaCode
        self.state = state
        self.stateCode = stateCode
        self.postalCode = postalCode
        self.city = city
        self.borough = borough
        self.county = county
        self.neighborhood = neighborhood
        self.number = number
        self.addressLabel = addressLabel
        self.placeLabel = placeLabel
        self.confidence = confidence
    }
    
    convenience init(_ dict: [AnyHashable : Any]) {
        let latitude = dict["latitude"] as? NSNumber
        let longitude = dict["longitude"] as? NSNumber
        var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
        let formattedAddress = dict["formattedAddress"] as? String
        let country = dict["country"] as? String
        let countryCode = dict["countryCode"] as? String
        let countryFlag = dict["countryFlag"] as? String
        let dma = dict["dma"] as? String
        let dmaCode = dict["dmaCode"] as? String
        let state = dict["state"] as? String
        let stateCode = dict["stateCode"] as? String
        let postalCode = dict["postalCode"] as? String
        let city = dict["city"] as? String
        let borough = dict["borough"] as? String
        let county = dict["county"] as? String
        let neighborhood = dict["neighborhood"] as? String
        let number = dict["number"] as? String
        let addressLabel = dict["addressLabel"] as? String
        let placeLabel = dict["placeLabel"] as? String
        var confidence: RadarAddressConfidence = .none
        
        if let lat = latitude, let lon = longitude {
            coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(lat.doubleValue), CLLocationDegrees(lon.doubleValue))
        }
        
        if let confidenceStr = dict["confidence"] as? String {
            if confidenceStr.caseInsensitiveCompare("exact") == .orderedSame  {
                confidence = .exact
            } else if confidenceStr.caseInsensitiveCompare("interpolated") == .orderedSame  {
                confidence = .interpolated
            } else if confidenceStr.caseInsensitiveCompare("fallback") == .orderedSame  {
                confidence = .fallback
            }
        }
        
        self.init(coordinate: coordinate, formattedAddress: formattedAddress, country: country, countryCode: countryCode, countryFlag: countryFlag, dma: dma, dmaCode: dmaCode, state: state, stateCode: stateCode, postalCode: postalCode, city: city, borough: borough, county: county, neighborhood: neighborhood, number: number, addressLabel: addressLabel, placeLabel: placeLabel, confidence: confidence)
        
    }
    
    static func addresses(_ addressesArr: [AnyHashable]) -> [RadarAddress]? {
        var mutableAddresses: [RadarAddress] = []
        for adressObj in addressesArr {
            if let adressDict = adressObj as? [AnyHashable : Any] {
                mutableAddresses.append(RadarAddress(adressDict))
            }else {
                return nil
            }
        }
        return mutableAddresses
    }
    
    static func array(forAddresses addresses: [RadarAddress]?) -> [[AnyHashable : Any]]? {
        if addresses == nil {
            return nil
        }
        var arr = [[AnyHashable : Any]]()
        for address in addresses ?? [] {
            let dict = address.dictionaryValue()
            arr.append(dict)
        }
        return arr
    }
    
    static func string(for confidence: RadarAddressConfidence) -> String {
        switch confidence {
        case .exact:
            return "exact"
        case .interpolated:
            return "interpolated"
        case .fallback:
            return "fallback"
        default:
            return "none"
        }
    }
    
    func dictionaryValue() -> [AnyHashable : Any] {
        var dict: [AnyHashable : Any] = [:]
        dict["latitude"] = coordinate.latitude
        dict["longitude"] = coordinate.longitude
        dict["formattedAddress"] = formattedAddress
        dict["country"] = country
        dict["countryCode"] = countryCode
        dict["countryFlag"] = countryFlag
        dict["dma"] = dma
        dict["dmaCode"] = dmaCode
        dict["state"] = state
        dict["stateCode"] = stateCode
        dict["postalCode"] = postalCode
        dict["city"] = city
        dict["borough"] = borough
        dict["county"] = county
        dict["neighborhood"] = neighborhood
        dict["number"] = number
        dict["addressLabel"] = addressLabel
        dict["placeLabel"] = placeLabel
        dict["confidence"] = RadarAddress.string(for: confidence)
        return dict
    }
    
}
