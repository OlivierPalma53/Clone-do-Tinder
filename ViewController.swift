//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBAction func singInFacebook(sender: AnyObject) {
        
        let permissions = ["public_profile", "email"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user: PFUser?, error: NSError?) -> Void in
            
            if let error = error {
                
                print(error)
                
            } else {
                
                if let user = user {
                    
                    if let intessedInWoman = user["intessedInWoman"]{
                        
                        self.performSegueWithIdentifier("logUserIn", sender: self)
                        
                    }else{
                        
                        self.performSegueWithIdentifier("showSignInScreen", sender: self)
                    }
                }
                
            }
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        if let username = PFUser.currentUser()?.username{
            
            if let intessedInWoman = PFUser.currentUser()?["intessedInWoman"]{
                
                self.performSegueWithIdentifier("logUserIn", sender: self)
                
            }else {
                self.performSegueWithIdentifier("showSignInScreen", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

