//
//  BaseCell.swift
//  BA-Clock
//
//  Created by April on 8/3/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

class BaseCell: UITableViewCell {
    
    
    //    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    //        super.init(style: style, reuseIdentifier: reuseIdentifier)
    //
    //    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for a in self.contentView.subviews {
            if a.frame.width == 1 {
                for b in a.constraints{
                    b.constant = 1.0 / UIScreen.mainScreen().scale
                }
            }
        }
        let v = UIView()
        self.contentView.addSubview(v)
        v.backgroundColor = CConstants.BorderColor
        let leadingConstraint = NSLayoutConstraint(item:v,
                                                   attribute: .LeadingMargin,
                                                   relatedBy: .Equal,
                                                   toItem: self.contentView,
                                                   attribute: .LeadingMargin,
                                                   multiplier: 1.0,
                                                   constant: 0);
        let trailingConstraint = NSLayoutConstraint(item:v,
                                                    attribute: .TrailingMargin,
                                                    relatedBy: .Equal,
                                                    toItem: self.contentView,
                                                    attribute: .TrailingMargin,
                                                    multiplier: 1.0,
                                                    constant: 0);
        
        let bottomConstraint = NSLayoutConstraint(item: v,
                                                  attribute: .BottomMargin,
                                                  relatedBy: .Equal,
                                                  toItem: self.contentView,
                                                  attribute: .BottomMargin,
                                                  multiplier: 1.0,
                                                  constant: 0);
        
        let heightContraint = NSLayoutConstraint(item: v,
                                                 attribute: .Height,
                                                 relatedBy: .Equal,
                                                 toItem: nil,
                                                 attribute: .NotAnAttribute,
                                                 multiplier: 1.0,
                                                 constant: 1.0 / (UIScreen.mainScreen().scale));
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, bottomConstraint, heightContraint])
    }
    
//    @IBOutlet var lbl: UILabel!
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        self.setCellBackColor(highlighted)
    }
//    @IBOutlet var seperatorHeight: NSLayoutConstraint!{
//        didSet{
//            seperatorHeight.constant = 1.0 / UIScreen.mainScreen().scale
//            self.updateConstraintsIfNeeded()
//        }
//    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setCellBackColor(selected)
    }
    
    private func setCellBackColor(sels: Bool){
        if sels {
            let a = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
            self.backgroundColor = a
            self.contentView.backgroundColor = a
        }else{
            self.backgroundColor = UIColor.whiteColor()
            self.contentView.backgroundColor = UIColor.whiteColor()
        }
    }
    
}

