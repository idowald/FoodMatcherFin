//
//  FavoritesViewController.swift
//  FoodMatcher
//
//  Created by Ido Wald and Tal Ron on 6.7.2016.
//  Copyright © 2016 medroid. All rights reserved.
//

import UIKit
import Parse

class FavoritesViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var dishChoose: String?
    var tableSource: [Dish]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.tableSource = []
    }
    
    func setFavoriteDishes(dishes: [PFObject]){
        self.tableSource = []
        if dishes.count > 0{
            for i in 0...dishes.count-1
            {
                self.tableSource?.append(Dish(dishObject: dishes[i]))
            }
        }

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableSource!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dishCell", forIndexPath: indexPath)
        cell.textLabel?.text = tableSource![indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dishChoose = self.tableSource![indexPath.row].dishObject.objectId
        self.performSegueWithIdentifier("dishViewController", sender:self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "dishViewController"){
            // variable to send
            let dishId = self.dishChoose
            // Create a new variable to store the instance of PlayerTableViewController
            let destinationVC = segue.destinationViewController as! DishViewController
            destinationVC.dishId = dishId!
            destinationVC.parentController = "favorites"
        }
        else{
            return
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        Dish.getDishFromLocal(setFavoriteDishes)
    }
    
    
}
