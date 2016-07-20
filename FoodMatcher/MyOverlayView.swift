//
//  MyOverlayView.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 1.7.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import Foundation
import Koloda

private let overlayRightImageName = "yesOverlayImage"
private let overlayLeftImageName = "noOverlayImage"

class MyOverlayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .Left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .Right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
        }
    }
    
}
