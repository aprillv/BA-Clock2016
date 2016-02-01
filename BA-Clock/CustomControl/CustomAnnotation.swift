//
//  CustomAnnotation.swift
//  BA-Clock
//
//  Created by April on 2/1/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
      var title: String? = ""
      var subtitle: String? = ""
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
