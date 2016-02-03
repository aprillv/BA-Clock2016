//
//  MapViewController.swift
//  BA-Clock
//
//  Created by April on 2/1/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var coordinate : CLLocationCoordinate2D?{
        didSet{
            updateMap()
        }
    }
    @IBOutlet weak var map: MKMapView!{
        didSet{
            map.layoutMargins = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 10)
            updateMap()
        }
    }
    @IBAction func closeself(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateMap(){
        if let coordinateTmp = coordinate,
            let mapTmp = map{
                let region = mapTmp.regionThatFits(MKCoordinateRegion.init(center: coordinateTmp, span: MKCoordinateSpanMake(0.02, 0.02)));
                mapTmp.setRegion(region, animated: true)
                
                let annotation : CustomAnnotation = CustomAnnotation(coordinate: coordinateTmp)
                annotation.coordinate = self.coordinate!
                mapTmp.addAnnotation(annotation)
                
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
     var annotationView : MKPinAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("April") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "April")
        }
        annotationView?.pinTintColor = UIColor.redColor()
        annotationView?.animatesDrop = true
        return annotationView
    
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
