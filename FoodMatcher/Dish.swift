//
//  Dish.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 30.6.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import Foundation
import Parse

class Dish:NSObject {
    var dishObject: PFObject

    
    init(name: NSString, price:Double, dishDescription: NSString, imageUrl: NSString, tags:[NSString], restaurant: Restaurant) {
        self.dishObject = PFObject(className: "Dish")
        
        self.dishObject["name"] = name
        self.dishObject["image"] = imageUrl
        self.dishObject["price"] = price
        self.dishObject["description"] = dishDescription
        self.dishObject["tags"] = tags
        self.dishObject["restaurant"] = restaurant.restaurantObject
        
    }
    
    init(dishObject: PFObject){
        self.dishObject = dishObject
    }
    
    var name : String {
        get { return self.dishObject.objectForKey("name") as! String }
    }
    
    var price : Double {
        get { return self.dishObject.objectForKey("price") as! Double }
    }
    
    var image : NSURL {
        get { return NSURL(string: self.dishObject.objectForKey("image") as! String)!}
    }
    
    var tags : [NSString] {
        get { return self.dishObject.objectForKey("tags") as! [NSString] }
    }
    
    var dishDescription : String {
        get { return self.dishObject.objectForKey("description") as! String }
    }
    
    var restaurant : Restaurant {
        get { let rest = self.dishObject.objectForKey("restaurant") as! PFObject
                return Restaurant(restaurant: rest)}
    }
    
    func saveInBackground(){
        self.dishObject.saveInBackground()
    }
    
    func saveInBackground(callback: (() -> Void)!){
        self.dishObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            callback()
        }
    }
    
    
    static func getDishById(dishId: NSString, callback:((parseDish: PFObject) -> Void)!){
        let query = PFQuery(className: "Dish")
        query.whereKey("objectId", equalTo: dishId)
        query.includeKey("restaurant")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    for dishObj in objects
                    {
                        callback(parseDish: dishObj)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    static func getDishFromLocal(callback:((dishes:[PFObject]) -> Void)!){
        
        let query = PFQuery(className: "Dish")
        query.fromLocalDatastore()
        
        query.findObjectsInBackground().continueWithBlock {
            (task: BFTask!) -> AnyObject in
            if let error = task.error {
                print("Error: \(error)")
                return task
            }
            callback(dishes: task.result! as! [PFObject])
            print("Retrieved \(task.result!.count)")
            return task
        }
        
    }
    
    static func getDishesByPrefrances(maxPrice: Int, maxDistance: Int, currentLocation:CLLocationCoordinate2D, callback:((dishes:[PFObject]) -> Void)!){
        
        let myGeoPoint = PFGeoPoint(latitude:currentLocation.latitude, longitude:currentLocation.longitude)
     
        let innerQuery = PFQuery(className: "Restaurant")
        innerQuery.whereKey("coords", nearGeoPoint: myGeoPoint, withinMiles: Double(maxDistance))
        
        let query = PFQuery(className:"Dish")
        query.addAscendingOrder("name")
        query.whereKey("price", lessThan: maxPrice)
        query.whereKey("restaurant", matchesQuery: innerQuery)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) dish.")
                
                // call callback function
                if let objects = objects {
                    callback(dishes: objects)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

    }
    

    
}