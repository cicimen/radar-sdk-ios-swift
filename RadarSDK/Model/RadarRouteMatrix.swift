//
//  RadarRouteMatrix.swift
//  RadarSDK
//
//  Created by Egemen Gulkilik on 14.10.2021.
//

import Foundation

/// Represents routes between multiple origins and destinations.
///
/// See [Matrix](https://radar.io/documentation/api#matrix).
class RadarRouteMatrix {
    
    /// Returns the route between the specified origin and destination.
    ///
    /// - Parameters:
    ///     - originIndex: The index of the origin.
    ///     - destinationIndex: The index of the destination.
    ///
    /// - Returns: The route between the specified origin and destination.
    func routeBetween(originIndex: Int, destinationIndex: Int) -> RadarRoute? {
        if originIndex >= matrix.count {
            return nil
        }
        let routes = matrix[originIndex]
        if destinationIndex >= routes.count {
            return nil
        }
        return routes[destinationIndex]
    }
    
    private var matrix: [[RadarRoute]] = []
    
    init(matrix: [[RadarRoute]]) {
        self.matrix = matrix
    }
    
    convenience init(_ rows: [AnyHashable]) {
        var matrix = [[RadarRoute]]()
        for row in rows {
            var routes = [RadarRoute]()
            if let col = row as? [AnyHashable] {
                for c in col {
                    if let cDict = c as? [AnyHashable: Any], let route = RadarRoute(cDict) {
                        routes.append(route)
                    }
                }
            }
            matrix.append(routes)
        }
        self.init(matrix: matrix)
    }
    
    func arrayValue() -> [[[AnyHashable : Any]]] {
        var rows = [[[AnyHashable : Any]]]()
        for routes in matrix {
            var col = [[AnyHashable : Any]]()
            for route in routes {
                col.append(route.dictionaryValue())
            }
            rows.append(col)
        }
        return rows
    }
    
}
