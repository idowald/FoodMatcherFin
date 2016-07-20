//
//  DishViewController.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 2.7.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import Foundation
import UIKit
import Parse

class DishViewController: UIViewController {

    var dishId: NSString = ""
    var parentController: NSString = ""
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dishImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    var dish: Dish?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Dish.getDishById(dishId, callback: setData)

    }
    
    func setData(parseDish: PFObject){
        
        self.dish = Dish(dishObject: parseDish)
        
        self.nameLabel.text = self.dish!.name
        
        if let data = NSData(contentsOfURL: (self.dish?.image)!) {
            dishImage.image = UIImage(data: data)
        }
        
        self.priceLabel.text = String(self.dish!.price) + " ₪"
        
        self.placeLabel.text = self.dish!.restaurant.name + " " + self.dish!.restaurant.address
        self.phoneLabel.text = self.dish!.restaurant.phone
        self.descriptionLabel.text = self.dish!.dishDescription
        var tagsString = ""
        for tag in self.dish!.tags
        {
            tagsString += (tag as String) + ", "
        }
        self.tagsLabel.text = tagsString
        self.spinner.stopAnimating()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func likePress(sender: AnyObject) {
        defaults.setInteger(1, forKey: "select")
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func dislikePress(sender: AnyObject) {
        defaults.setInteger(2, forKey: "select")
        navigationController?.popViewControllerAnimated(true)
    }

    
    override func viewWillAppear(animated: Bool) {
        if parentController.isEqualToString("favorites"){
            selectView.hidden = true
        }
        else{
            removeButton.hidden = true
        }
    }
    
    @IBAction func removeFromFavorites(sender: AnyObject) {
        self.dish?.dishObject.unpinInBackgroundWithBlock({ (resultBool, error) -> Void in
            if error != nil { return }
                self.navigationController?.popViewControllerAnimated(true)
            }
        )
        
    }
    
}