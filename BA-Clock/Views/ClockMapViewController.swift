//
//  ClockMapViewController.swift
//  BA-Clock
//
//  Created by April on 1/12/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

class ClockMapViewController: BaseViewController {
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:red|%f,%f&%@&sensor=true",yourLatitude, yourLongitude,@"zoom=10&size=270x70"];
//        NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
        
        let mapUrl = "https://maps.google.com/maps/api/staticmap?markers=color:red|29.751872,-95.362037&zoom=14&size=200x200&sensor=true"
        if let url : NSURL = NSURL(string: mapUrl) {
            if let data1 = NSData(contentsOfURL: url) {
                if let image = UIImage(data: data1){
                    imageView.image = image
                }
            }
            
        }
        
        
    }
}
