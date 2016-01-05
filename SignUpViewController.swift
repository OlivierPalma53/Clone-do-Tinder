//
//  SignUpViewController.swift
//  ParseStarterProject
//
//  Created by Olivier Palma on 19/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var intessedInWoman: UISwitch!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBAction func signUp(sender: AnyObject) {
        
        PFUser.currentUser()?["intessedInWoman"] = intessedInWoman.on
        PFUser.currentUser()?.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, gender, email"])
        
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error != nil{
                print(error)
            } else if let result = result {
                
                PFUser.currentUser()?["name"] = result["name"]
                PFUser.currentUser()?["gender"] = result["gender"]
                PFUser.currentUser()?["email"] = result["email"]

                PFUser.currentUser()?.save()
                
                let userId = result["id"] as! String
                
                let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                
                if let fbPicUrl = NSURL(string: facebookProfilePictureUrl){
                    
                    if let data = NSData(contentsOfURL: fbPicUrl) {
                        
                        self.userImage.image = UIImage(data: data)
                        let imageFile = PFFile(data: data)
                        
                        PFUser.currentUser()?["imageProfile"] = imageFile
                        
                        PFUser.currentUser()?.save()
                        
                        self.usernameLabel.text = result["name"] as! String
                    }
                    
                }
                
                
                
            }
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}
