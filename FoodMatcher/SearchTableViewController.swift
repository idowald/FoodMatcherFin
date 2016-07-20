//
//  SearchTableViewController.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 15.7.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, CLLocationManagerDelegate {
    
    var dishChoose: String?
    var tableData = [Dish]()
    var filteredTableData = [Dish]()
    var resultSearchController = UISearchController()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        let maxPrice = getUserMaxPrice()
        let maxDistance = getUserMaxDistance()
        
        locationInit()
        let center = getMyLocation()
        
        Dish.getDishesByPrefrances(maxPrice, maxDistance: maxDistance, currentLocation: center, callback: setData)
        
        
    }
    
    func setData(parseDishes:[PFObject]){
        
        for dish in parseDishes{
            self.tableData.append(Dish(dishObject: dish))
        }
        // Reload the table
        self.tableView.reloadData()
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if (self.resultSearchController.active) {
            return self.filteredTableData.count
        }
        else {
            return self.tableData.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if (self.resultSearchController.active) {
            cell.textLabel?.text = filteredTableData[indexPath.row].name
            
            return cell
        }
        else {
            cell.textLabel?.text = tableData[indexPath.row].name
            
            return cell
        }
    }
 
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredTableData.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (tableData as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [Dish]
        
        self.tableView.reloadData()
    }

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dishChoose = self.tableData[indexPath.row].dishObject.objectId
        self.performSegueWithIdentifier("dishViewController", sender:self)
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

}
