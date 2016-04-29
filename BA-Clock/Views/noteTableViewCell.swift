//
//  noteTableViewCell.swift
//  BA-Clock
//
//  Created by April on 4/29/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

class noteTableViewCell: UITableViewCell {

    @IBOutlet var txtView: UITextView!{
        didSet{
            txtView.layer.cornerRadius = 5.0
            txtView.layer.borderColor = CConstants.BorderColor.CGColor
            txtView.layer.borderWidth = 1.0 / (UIScreen().scale)
            
            
            
        }
    }
}
