//
//  CardView.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 30.6.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import Foundation
import UIKit
import Koloda

class CardView: UIView{
    var image: UIImageView = UIImageView()
    var dishDescription: UILabel = UILabel()
   // var whiteImage: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCustomView()
    }
    
    required init() {
        super.init(frame: .zero)
        addCustomView()
        setupLayout()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    // MARK: Build View hierarchy
    
    func addCustomView(){
        
        image.frame = CGRectMake(0, 50, 290, 280)
        self.addSubview(image)
        
        dishDescription.frame = CGRectMake(0, 330, 300, 100)
        dishDescription.numberOfLines = 3
        dishDescription.backgroundColor = UIColor.whiteColor()
//        label.center = CGPointMake(160, 284)
//        label.textAlignment = NSTextAlignment.Center
        
        self.addSubview(dishDescription)
        
    }
    
    func setupLayout(){
        // Autolayout
    }

}