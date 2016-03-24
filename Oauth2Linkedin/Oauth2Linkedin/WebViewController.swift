//
//  WebViewController.swift
//  Oauth2Linkedin
//
//  Created by Ethan Hess on 3/24/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    let linkedInKey = "75zs3dlkd1hgu8"
    let linkedInSecret = "SqWclKYYy1NWtsOT"
    let authorizationEndPoint = "https://www.linkedin.com/uas/oauth2/authorization"
    let accessTokenEndPoint = "https://www.linkedin.com/uas/oauth2/accessToken"

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        
        startAuthorization()
    }
    
    func startAuthorization() {
        
        let responseType = "code"
        
        let redirectURL = "https://com.appcoda.linkedin.oauth/oauth".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        
        let scope = "r_basicprofile"
        
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(linkedInKey)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        print(authorizationURL)
        
        let request = NSURLRequest(URL: NSURL(string: authorizationURL)!)
        webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url = request.URL!
        print(url)
        
        if url.host == "com.appcoda.linkedin.oauth" {
            if url.absoluteString.rangeOfString("code") != nil {
                
                //extract auth code
                let urlParts = url.absoluteString.componentsSeparatedByString("?")
                let code = urlParts[1].componentsSeparatedByString("=")[1]
                
                requestForAccessToken(code)
            }
        }
        
        return true
    }

    func requestForAccessToken(authorizationCode: String) {
        
        let grantType = "authorization_code"
        
        let redirectURL = "https://com.appcoda.linkedin.oauth/oauth".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(linkedInKey)&"
        postParams += "client_secret=\(linkedInSecret)"
        
        //encode post params
        let postData = postParams.dataUsingEncoding(NSUTF8StringEncoding)
        
        //set up request
        let request = NSMutableURLRequest(URL: NSURL(string: accessTokenEndPoint)!)

        request.HTTPMethod = "POST"
        
        request.HTTPBody = postData

        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        //init session
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if statusCode == 200 {
                
                do {
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    
                    let accessToken = dataDictionary["access_token"] as! String
                    
                    NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "LIAccessToken")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }
            
        }
        
        task.resume()
        
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
