//
//  ViewController.swift
//  animate
//
//  Created by admin on 5/6/16.
//  Copyright © 2016 Anya&Qusay. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse
import pop

class NewDishViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLUploaderDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var vegiBox: CheckBox!
    @IBOutlet weak var kasherBox: CheckBox!
    @IBOutlet weak var placeTextField: UITextField!
    
    @IBOutlet weak var image: UIImageView!
    var dishImage: UIImage!
    
    var placePicker: GMSPlacePicker?
    var restaurant: Restaurant?
    
    var imageUrl: NSString?
    
    @IBOutlet weak var dishDescription: UITextView!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var name: UITextField!
    
    let imagePicker = UIImagePickerController()
    var firstTime: Bool = true
    
    var cloudinary:CLCloudinary!
    var Timestamp: String {
        return "\(NSDate().timeIntervalSince1970 * 10000)"
    }
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        price.keyboardType = UIKeyboardType.NumbersAndPunctuation
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .PhotoLibrary
        
        //check if there is camera available
        if(UIImagePickerController.isSourceTypeAvailable(.Camera))
        {
            imagePicker.sourceType = .Camera
        }
        
        
        //add on click function to imageview
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(NewDishViewController.imageTapped(_:)))
        image.userInteractionEnabled = true
        image.addGestureRecognizer(tapGestureRecognizer)
        
        cloudinary = CLCloudinary() //url: "cloudinary://yours:yours"
        
        cloudinary.config().setValue("dbfoodmatcher", forKey: "cloud_name")
        cloudinary.config().setValue("919926487991878", forKey: "api_key")
        cloudinary.config().setValue("tSu-bgg5Squ21vaCJstyUyaJUxg", forKey: "api_secret")
        
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        
        locationInit()
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    }
    
    //take new image whem image click
    func imageTapped(img: AnyObject)
    {
       self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if(firstTime){
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            firstTime = false
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of anhat can be recreated.
    }
    
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            
            dishImage = self.ResizeImage(pickedImage, targetSize: CGSizeMake(200.0, 200.0))
            
            
            //dishImage = pickedImage
           // let fullPath = uiImageToFile(pickedImage)
            //info[UIImagePickerControllerReferenceURL] as! NSURL
            self.image.contentMode = .ScaleToFill
            self.image.image = dishImage
            
        }
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func uiImageToFile(pickedImage: UIImage) -> String
    {
        let imageData = NSData(data:UIImagePNGRepresentation(pickedImage)!)
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docs: String = paths[0]
        let fullPath = docs.stringByAppendingString(".jpg")
        imageData.writeToFile(fullPath, atomically: true)
        return fullPath
    }
    
    
    @IBAction func saveDish(sender: AnyObject) {
        if(image.image == nil){
            self.shake(image)
            return
        }
        if (name.text == "") {
            //makeToast("Please enter dish name.")
            self.shake(name)
            return
        }
        if (price.text == "") {
            //makeToast("Please enter dish name.")
            self.shake(price)
            return
        }
        if (dishDescription == "") {
            //makeToast("Please enter dish name.")
            self.shake(dishDescription)
            return
        }
        if (placeTextField.text == "") {
            //makeToast("Please enter dish name.")
            self.shake(placeButton)
            return
        }
        let imageFileName = Timestamp
        uploadToCloudinary(imageFileName)
    }
    

    @IBAction func openPlacePicker(sender: AnyObject) {
        
        guard let center = locationManager.location?.coordinate else {print("No coordinates"); return}
                let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
                let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
                let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                let config = GMSPlacePickerConfig(viewport: viewport)
                placePicker = GMSPlacePicker(config: config)
        
                placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
                    if let error = error {
                        print("Pick Place error: \(error.localizedDescription)")
                        return
                    }
            
                    if let place = place {
                        self.placeTextField.text = place.name
                        self.restaurant = Restaurant(location: center, name: place.name, phone: place.phoneNumber!, address: place.formattedAddress!, rating: place.rating, googleId: place.placeID)
//                        print("Place name \(place.name)")
//                        print("Place address \(place.formattedAddress)")
//                        print("Place attributions \(place.attributions)")
                    } else {
                        print("No place selected")
                    }
                })
    }
    
    
    
    //upload image
    
    
    func uploadToCloudinary(fileId:String){
        //guard let image=self.dishImage else {return}
        spinner.startAnimating()
        let forUpload = UIImagePNGRepresentation(dishImage)! as NSData
        let uploader = CLUploader(cloudinary, delegate: self)
        
        uploader.upload(forUpload, options: ["public_id":fileId],
                        withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
        
    }
    
    func onCloudinaryCompletion(successResult:[NSObject : AnyObject]!, errorResult:String!, code:Int, idContext:AnyObject!) {
        
        self.imageUrl = successResult["secure_url"] as? NSString
        
        findRestaurant()
        
        

        
        let fileId = successResult["public_id"] as! String
        uploadDetailsToServer(fileId)
        
    }
    
    func findRestaurant()
    {
        let query = PFQuery(className: "Restaurant")
        
        query.whereKey("googleId", equalTo: (self.restaurant?.googleId)!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    if (objects.count > 0 ){
                        self.restaurant?.restaurantObject = objects[0]
                        self.addNewDIsh()
                    } else{
                        //create new resturant - after save-> go to save dish
                        self.addNewRestaurant()
                    }
                    for object in objects {
                        print(object.objectId)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }


    }
    
    func addNewRestaurant(){
      
        self.restaurant?.saveRestaurant(self.addNewDIsh)
        

    }
    
    func addNewDIsh(){
        guard let priceDish = self.price.text else {return}
        let price = Double(priceDish)
        
        var tags: [NSString]
        tags = []
        if kasherBox.isChecked {
            tags.append("Kasher")
        }
        if vegiBox.isChecked {
            tags.append("Vegiterian")
        }
        
        let dish = Dish(name: name.text!, price: price!, dishDescription: dishDescription.text!, imageUrl: String(self.imageUrl!), tags: tags, restaurant: self.restaurant!)
        
        
        dish.saveInBackground(onSaveComplete)
        
        }
    

    func onSaveComplete(){
        self.spinner.stopAnimating()
        print("Object has been saved.")
        self.dismissViewControllerAnimated(true, completion: {})
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewControllerWithIdentifier("SWRevealViewController")
        self.presentViewController(main, animated: true, completion: nil)
        

    }

    func uploadDetailsToServer(fileId:String){
        //upload your metadata to your rest endpoint
    }
    
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:AnyObject!) {
        //do any progress update you may need
    }
    
    
    ///////
     
 
    func makeToast(message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func shake(view: UIView)
    {
        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake.springBounciness = 20
        shake.velocity = NSNumber(int: 3000)
        view.layer.pop_addAnimation(shake, forKey: "shakePassword")
    }

    
    
    

    
}

