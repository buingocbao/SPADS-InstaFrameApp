//
//  ViewController.swift
//  SPADS-InstaFrameApp
//
//  Created by BBaoBao on 6/1/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let placeName = "Frame"
        
        let url = NSURL(string: "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=\(placeName)")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){ (response, go, error) -> Void in
            
            let go = NSJSONSerialization.JSONObjectWithData(go, options: NSJSONReadingOptions.AllowFragments, error: nil) as! [String:AnyObject]
            let responseData = go["responseData"] as! [String:AnyObject]
            // let results = responseData["results"] as [String:AnyObject]
            // let imageURL = results["unescapedUrl"] as String
            
            let result = responseData["results"] as! [[String:String]]
            let firstObject = result[0]
            let firstURL = firstObject["unescapedUrl"]
            println(responseData)
            println(firstObject)
            println(firstURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

