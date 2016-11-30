//
//  MKGPX.swift
//  Trax
//
//  Created by Simen Gangstad on 30.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation
import MapKit

extension GPX.Waypoint : MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    var title: String? { return name }
    var subtitle: String? { return info }
    var thumbnailURL: URL? { return getImageURLOfType(type: "thumbnail") }
    var imageURL: URL? {return getImageURLOfType(type: "large")}
    private func getImageURLOfType(type: String?) -> URL? {
        for link in links {
            if link.type == type {
                return link.url
            }
        }
        return nil
    }
}
