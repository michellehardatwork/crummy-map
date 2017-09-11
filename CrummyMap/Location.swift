//
//  Location.swift
//  CrummyMap
//
//  Created by Cervenka, Michelle on 9/9/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import Foundation
import MapKit

struct Location {
    var description: String
    var degrees: CLLocationCoordinate2D

    init(description: String, degrees: CLLocationCoordinate2D) {
        self.description = description
        self.degrees = degrees
    }

    init?(json: JSONDictionary) {
        guard let formattedName = json["formatted"] as? String,
            let coordinates = json["geometry"] as? JSONDictionary,
            let latitude = coordinates["lat"] as? CLLocationDegrees,
            let longitude = coordinates["lng"] as? CLLocationDegrees else {
                return nil
        }

        self.degrees = CLLocationCoordinate2DMake(latitude, longitude)
        self.description = formattedName
    }
}
