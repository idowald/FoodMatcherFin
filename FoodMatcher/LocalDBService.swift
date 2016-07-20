//
//  LocalDBService.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 18.7.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import Foundation

func getUserMaxPrice() -> Int{
    
    var maxPrice: Int
    let userSettings = NSUserDefaults.standardUserDefaults()
    let priceValue = userSettings.integerForKey("price")
    if (priceValue > 0){
        maxPrice = priceValue
    }
    else{
        maxPrice = 150
    }
    return maxPrice
}

func getUserMaxDistance() -> Int{
    let userSettings = NSUserDefaults.standardUserDefaults()
    var maxDistance: Int
    let distanceValue = userSettings.integerForKey("distance")
    if (distanceValue > 0){
        maxDistance = distanceValue
    }
    else{
        maxDistance = 20
    }
    return maxDistance
}