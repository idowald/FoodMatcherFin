//
//  SettingsViewController.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 6.7.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        
        let priceValue = getUserMaxPrice()
        priceLabel.text = "\(priceValue)"
        priceSlider.setValue(Float(priceValue), animated: true)
        
        let distanceValue = getUserMaxDistance()
        distanceLabel.text = "\(distanceValue)"
        distanceSlider.setValue(Float(distanceValue), animated: true)
        
    }
    
    
    @IBAction func priceValueChanged(sender: AnyObject) {
        let currentValue = Int(priceSlider.value)
        
        priceLabel.text = "\(currentValue)"
        
        defaults.setInteger(currentValue, forKey: "price")
        defaults.synchronize()
        
    }
    
    @IBAction func distanceValueChanged(sender: AnyObject) {
        let distanceCurrentValue = Int(distanceSlider.value)
        
        distanceLabel.text = "\(distanceCurrentValue)"
        
        defaults.setInteger(distanceCurrentValue, forKey: "distance")
        defaults.synchronize()
    }

}
