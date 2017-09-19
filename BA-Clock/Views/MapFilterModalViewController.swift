//
//  MapFilterModalViewController.swift
//  BA-Clock
//
//  Created by April Lv on 9/16/17.
//  Copyright © 2017 BuildersAccess. All rights reserved.
//

import UIKit
import DatePickerDialog

protocol MapFilterModalViewDelegate {
    func doRefresh(from: String, to: String)
}

class MapFilterModalViewController: BaseViewController {

    var delegate : MapFilterModalViewDelegate?
    
    @IBOutlet weak var line: UIView!{
        didSet{
            line.backgroundColor = UIColor.init(red: 234/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
        }
    }
    @IBOutlet weak var BigBackView: UIView!{
        didSet{
            BigBackView.backgroundColor = UIColor.init(red: 239/255.0, green: 240/255.0, blue: 246/255.0, alpha: 1.0)
            BigBackView.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet weak var searchbutton: UIButton!{
        didSet{
            searchbutton.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var cancelbutton: UIButton!{
        didSet{
            cancelbutton.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var firstTextBox: UIView!{
        didSet{
            firstTextBox.layer.borderColor = UIColor.init(red: 220/255.0, green: 218/255.0, blue: 224/255.0, alpha: 1.0).cgColor
            firstTextBox.layer.borderWidth = 1.0
            firstTextBox.backgroundColor = UIColor.white
        }
    }
    @IBOutlet weak var secordTextBox: UIView!{
        didSet{
            secordTextBox.layer.borderColor = UIColor.init(red: 220/255.0, green: 218/255.0, blue: 224/255.0, alpha: 1.0).cgColor
            secordTextBox.layer.borderWidth = 1.0
            secordTextBox.backgroundColor = UIColor.white
        }
    }
    @IBOutlet weak var fromdatelbl: UILabel!
    @IBOutlet weak var todatelbl: UILabel!
    @IBAction func frombtn(_ sender: UIButton) {
        
        DatePickerDialog().show(
            title: "From Date"
        , doneButtonTitle: "Done"
        , cancelButtonTitle: "Cancel"
        , defaultDate: self.fromDateV!
        , minimumDate: nil
        , maximumDate: nil
        , datePickerMode: .date){
            (date) -> Void in
            if let dt = date {
                self.fromDateV = dt;
            }

        }
        
    }
    @IBAction func tobtn(_ sender: UIButton) {
        DatePickerDialog().show(
            title: "To Date"
            , doneButtonTitle: "Done"
            , cancelButtonTitle: "Cancel"
            , defaultDate: self.toDateV!
            , minimumDate: nil
            , maximumDate: nil
        , datePickerMode: .date){
            (date) -> Void in
            if let dt = date {
                self.toDateV = dt;
            }
        }
    }
    
    private var fromDateV: Date? {
        didSet{
            self.fromdatelbl?.text = self.getDateFormat().string(from: fromDateV ?? Date())
            if self.fromDateV!.timeIntervalSince(self.toDateV ?? Date()) > 0 {
                self.toDateV = self.fromDateV
            }
            
        }
    }
    private var toDateV: Date? {
        didSet{
            self.todatelbl?.text = self.getDateFormat().string(from: toDateV ?? Date())
            if self.fromDateV!.timeIntervalSince(self.toDateV ?? Date()) > 0 {
                self.fromDateV = self.toDateV
            }
            
        }
    }
    
    private func getDateFormat() -> DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    @IBAction func doSearch(_ sender: UIButton) {
//        MM/dd/yyyy
        self.dismiss(animated: true) {
            self.delegate?.doRefresh(from: self.fromdatelbl.text ?? "", to: self.todatelbl.text ?? "")
        }
    }
    @IBAction func doCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.2, alpha: 0.5)
        view.isOpaque = true
        
        
        self.fromDateV = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        
        self.toDateV = Date()
    }

}
