//
//  ViewController.swift
//  animate
//
//  Created by admin on 5/6/16.
//  Copyright © 2016 Anya&Qusay. All rights reserved.
//

import UIKit
import Parse
import Koloda

private var numberOfCards: UInt = 1

class ViewController: UIViewController, KolodaViewDelegate, KolodaViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var noDishLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
   

    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var cardsView: KolodaView!
    
    var currentIndex = 0
    
    private var dishSource: Array<Dish> = []
    private var dishes: Array<Dish> = []
    var dishChoose: NSString?
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDishLabel.hidden = true
        selectView.hidden = true
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        
        let maxPrice = getUserMaxPrice()
        let maxDistance = getUserMaxDistance()
        
        
        locationInit()
        let center = getMyLocation()
        
        Dish.getDishesByPrefrances(maxPrice, maxDistance: maxDistance, currentLocation: center, callback: setData)
        
        
    }
    
    func setData(parseDishes:[PFObject]){
        
        for dish in parseDishes {
            self.dishes.append(Dish(dishObject: dish))
        }
        if self.dishes.count > 0{
            self.dishSource.append(self.dishes[0])
            selectView.hidden = false
        }
        else{
            noDishLabel.hidden = false
            selectView.hidden = true
        }
        self.cardsView.delegate = self
        self.cardsView.dataSource = self
        self.spinner.stopAnimating()
    }

    func getMyLocation() -> CLLocationCoordinate2D{
        guard let center = locationManager.location?.coordinate else { print("default location set."); return CLLocationCoordinate2DMake(30, 30)}
        
        return center
    }
    
    func locationInit(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //Dislike tapped
    @IBAction func dislikeButtonTapped() {
        cardsView?.swipe(SwipeResultDirection.Left)
    }
    
    //like tapped
    @IBAction func likeButtonTapped() {
        cardsView?.swipe(SwipeResultDirection.Right)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        dishSource.insert(self.dishes[cardsView.currentCardIndex%self.dishes.count], atIndex: cardsView.currentCardIndex)
        let position = cardsView.currentCardIndex
        cardsView.insertCardAtIndexRange(position...position, animated: true)
        
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        self.dishChoose = self.dishSource[Int(index)].dishObject.objectId
        self.performSegueWithIdentifier("dishViewController", sender:self)
        //UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "dishViewController"){
            // variable to send
            let dishId = self.dishChoose
            // Create a new variable to store the instance of PlayerTableViewController
            let destinationVC = segue.destinationViewController as! DishViewController
            destinationVC.dishId = dishId!
        }
        else{
            return
        }
        
    }


    
    func kolodaNumberOfCards(koloda:KolodaView) -> UInt {
        return UInt(dishSource.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let customView = CardView()
        
        if let data = NSData(contentsOfURL: dishSource[Int(index)].image) {
            customView.image.image = UIImage(data: data)
        }
        
        customView.dishDescription.text = dishSource[Int(index)].dishDescription
        
        return customView
//        return UIImageView(image: dataSource[Int(index)])
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }
    
    
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection){
        if (direction.rawValue.lowercaseString == "right"){
            // The user like the Dish
            saveDishToFavorites(dishSource[Int(index)])
        }
        
    }

    // save the id of the dish to local storage
    func saveDishToFavorites(dish: Dish){
        dish.dishObject.pinInBackground()
    }
    
    override func viewWillAppear(animated: Bool) {
        //if come back after user press like or dislike on the DishViewController
        let defaults = NSUserDefaults.standardUserDefaults()
        let buttonPress = defaults.integerForKey("select")
        if buttonPress > 0{
            if buttonPress == 1{    //user press like
                cardsView?.swipe(SwipeResultDirection.Right)
            }
            else{   // user pres dislike
                cardsView?.swipe(SwipeResultDirection.Left)
            }
            defaults.removeObjectForKey("select")
        }

       
    }
    
}

