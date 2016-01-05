//
//  SwipeViewController.swift
//  ParseStarterProject
//
//  Created by Olivier Palma on 19/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SwipeViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var displayedUserId = ""
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        
        let label = gesture.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200)
        
        let scale =  min(100 / abs(xFromCenter), 1)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        label.transform = stretch
        
        
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var acceptedOrRejected = ""
            
            if label.center.x < 100 {
                
                acceptedOrRejected = "rejected"
                
            } else if label.center.x > self.view.bounds.width - 100 {
                
                acceptedOrRejected = "accepted"
                
            }
            
            if acceptedOrRejected != "" {
                
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: acceptedOrRejected)
                PFUser.currentUser()?.save()
                
            }
            
            rotation = CGAffineTransformMakeRotation(0)
            
            stretch = CGAffineTransformScale(rotation, 1, 1)
            
            label.transform = stretch
            
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
            updateImage()
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        
        userImage.addGestureRecognizer(gesture)
        
        userImage.userInteractionEnabled = true
        
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if let geoPoint = geoPoint {
                
                PFUser.currentUser()?["location"] = geoPoint
                PFUser.currentUser()?.save()
                
            }
        }
    
        updateImage()
    }
    
    func updateImage(){
        
        let query = PFUser.query()
        
        if let latitude = PFUser.currentUser()?["location"]?.latitude {
            
            if let longitude = PFUser.currentUser()?["location"]?.longitude{
                
                query?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))

            }
            
        }

        
        var intessedIn = "male"
        
        if PFUser.currentUser()!["intessedInWoman"]! as! Bool == true {
            
            intessedIn = "female"
        }
        
        var isFemale = true
        
        if (PFUser.currentUser()?["gender"])! as! String == "male" {
            
            isFemale = false
            
        }
        
        query?.whereKey("gender", equalTo: intessedIn)
        query?.whereKey("intessedInWoman", equalTo: isFemale)
        
        var ignoredUsers = [String]()
        
        if let acceptedUsers = PFUser.currentUser()?["accepted"]{
            
            ignoredUsers += acceptedUsers as! Array
            
        }
        
        if let rejectedUsers = PFUser.currentUser()?["rejected"] {
            
            ignoredUsers += rejectedUsers as! Array
            
        }
        
        query?.whereKey("objectId", notContainedIn: ignoredUsers)
        
        query?.limit = 1
        
        query?.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error != nil {
                print(error)
            } else if let objects = objects as? [PFObject] {
                
                for object in objects {
                    
                    self.displayedUserId = object.objectId!
                    
                    let imageFile = object["imageProfile"] as! PFFile
                    imageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        
                        if error != nil {
                            
                            print(error)
                        } else{
                            
                            if let data = imageData {
                                
                                self.userImage.image = UIImage(data: data)
                                
                            }
                        }
                        
                    })
                    
                }
                
            }
            
        })

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logOut" {
            PFUser.logOut()
        }
    }
}
