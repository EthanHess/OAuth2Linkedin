//
//  ViewController.swift
//  Oauth2Linkedin
//
//  Created by Ethan Hess on 3/24/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var getProfileInfoButton: UIButton!
    @IBOutlet weak var openProfileButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForExistingAccessToken()
        
        signInButton.enabled = true
//        getProfileInfoButton.enabled = false
//        openProfileButton.hidden = true
    }
    
    func checkForExistingAccessToken() {
        
        if NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") != nil {
            
            signInButton.enabled = false
            getProfileInfoButton.enabled = true
        }
        
    }
    
    @IBAction func getProfileInfo(sender: AnyObject) {
        
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") {
            
            //set up request
            
            let targetURLString = "https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json"
            
            let request = NSMutableURLRequest(URL: NSURL(string: targetURLString)!)
            
            request.HTTPMethod = "GET"
            
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            //session init then make request
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    
                    do {
                        
                        let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        
                        let profileURLString = dataDictionary["publicProfileUrl"] as! String
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.openProfileButton.setTitle(profileURLString, forState: UIControlState.Normal)
                            self.openProfileButton.hidden = false
                            
                        })

                    }
                    
                    catch {
                        print("JSON conversion error!")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @IBAction func openProfileInSafari(sender: AnyObject) {
        
        let profileURL = NSURL(string: openProfileButton.titleForState(UIControlState.Normal)!)
        UIApplication.sharedApplication().openURL(profileURL!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

