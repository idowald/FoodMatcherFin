//
//  Restaurant.swift
//  FoodMatcher
//
//  Created by moshe Cohen on 30.6.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import Foundation
import CoreLocation
import Parse

class Restaurant{
    var restaurantObject: PFObject
    
    init(location: CLLocationCoordinate2D, name: NSString, phone: NSString, address: NSString, rating: Float, googleId: NSString) {
        self.restaurantObject = PFObject(className: "Restaurant")
        self.restaurantObject["name"] = name
        self.restaurantObject["phone"] = phone
        
        self.restaurantObject["rating"] = rating
        self.restaurantObject["address"] = address
        self.restaurantObject["coords"] = PFGeoPoint(latitude:location.latitude, longitude:location.longitude)
        self.restaurantObject["googleId"] = googleId
    }
    
    init(restaurant:PFObject)
    {
        self.restaurantObject = restaurant
    }
    
    func getRating() -> String
    {
        return self.restaurantObject.objectForKey("rating") as! String
    }
    
    var name : String {
        get { return self.restaurantObject.objectForKey("name") as! String }
    }
    
    var phone : String {
        get { return self.restaurantObject.objectForKey("phone") as! String }
    }
    
    var address : String {
        get { return self.restaurantObject.objectForKey("address") as! String }
    }
    
    var rating : String {
        get { return self.restaurantObject.objectForKey("rating") as! String }
    }
    
    var location : CLLocationCoordinate2D {
        get { let location = self.restaurantObject.objectForKey("coords") as! PFGeoPoint
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude) }
    }
    
    var googleId : String {
        get { return self.restaurantObject.objectForKey("googleId") as! String }
    }
    
    
    func saveRestaurant(callback: (() -> Void)!){
        self.restaurantObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            callback()
        }
    }
}