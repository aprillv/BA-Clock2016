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
                    b.constant = 1.0 / UIScreen.main.scale
                }
            }
        }
        let v = UIView()
        self.contentView.addSubview(v)
        v.backgroundColor = CConstants.BorderColor
        let leadingConstraint = NSLayoutConstraint(item:v,
                                                   attribute: .leadingMargin,
                                                   relatedBy: .equal,
                                                   toItem: self.contentView,
                                                   attribute: .leadingMargin,
                                                   multiplier: 1.0,
                                                   constant: 0);
        let trailingConstraint = NSLayoutConstraint(item:v,
                                                    attribute: .trailingMargin,
                                                    relatedBy: .equal,
                                                    toItem: self.contentView,
                                                    attribute: .trailingMargin,
                                                    multiplier: 1.0,
                                                    constant: 0);
        
        let bottomConstraint = NSLayoutConstraint(item: v,
                                                  attribute: .bottomMargin,
                                                  relatedBy: .equal,
                                                  toItem: self.contentView,
                                                  attribute: .bottomMargin,
                                                  multiplier: 1.0,
                                                  constant: 0);
        
        let heightContraint = NSLayoutConstraint(item: v,
                                                 attribute: .height,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1.0,
                                                 constant: 1.0 / (UIScreen.main.scale));
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, bottomConstraint, heightContraint])
    }
    
//    @IBOutlet var lbl: UILabel!
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.setCellBackColor(highlighted)
    }
//    @IBOutlet var seperatorHeight: NSLayoutConstraint!{
//        didSet{
//            seperatorHeight.constant = 1.0 / UIScreen.mainScreen().scale
//            self.updateConstraintsIfNeeded()
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setCellBackColor(selected)
    }
    
    fileprivate func setCellBackColor(_ sels: Bool){
        if sels {
            let a = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
            self.backgroundColor = a
            self.contentView.backgroundColor = a
        }else{
            self.backgroundColor = UIColor.white
            self.contentView.backgroundColor = UIColor.white
        }
    }
    
}

