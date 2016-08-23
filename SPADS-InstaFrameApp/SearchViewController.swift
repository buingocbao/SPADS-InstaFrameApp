//
//  SearchViewController.swift
//  SPADS-InstaFrameApp
//
//  Created by BBaoBao on 6/1/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit
import SystemConfiguration

class SearchViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var framePickCollectionView: UICollectionView!

    var colorPicked:String = String()
    var result:[[String:String]] = [[String:String]]()
    let nodeConstructionQueue = NSOperationQueue()
    var searchActive : Bool = false
    var url:NSURL!
    var placeName:String = ""
    var imageData:NSData!
    var btLoadFromLocal:MKButton = MKButton()
    var backButton:MKButton = MKButton()
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var picker:UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set delegate and DataSource
        if isConnectedToNetwork() == true {
            framePickCollectionView!.dataSource = self
            framePickCollectionView!.delegate = self
            
            // Show scroll bar
            framePickCollectionView.flashScrollIndicators()
            
            // Set navigation bar title
            self.navigationItem.title = colorPicked + " Frame"
            
            // Config activity Indicator
            
            //
            searchBar.delegate = self
            
            placeName = "free+\(colorPicked)+frame"
            
            self.searchGG(placeName)
            
            // Long press event
            var longPress = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
            longPress.minimumPressDuration = 0.5
            longPress.allowableMovement = 100.0
            longPress.delegate = self
            self.framePickCollectionView.addGestureRecognizer(longPress)
        } else {
            let alertController = UIAlertController(title: "Network Error", message:
                "Please try connect to Internet again, or you can load frame by local image.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        addButtonToNavigationBar()
        
        picker.delegate = self
        
    }
    
    func addButtonToNavigationBar() {
        // Add left bar button
        // hide default navigation bar button item
        self.navigationItem.backBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = true;
        
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        backButton.backgroundColor = UIColor.MKColor.Green
        backButton.cornerRadius = 20.0
        backButton.backgroundLayerCornerRadius = 20.0
        backButton.maskEnabled = false
        backButton.circleGrowRatioMax = 1.75
        backButton.rippleLocation = .Center
        backButton.aniDuration = 0.85
        backButton.layer.shadowOpacity = 0.75
        backButton.layer.shadowRadius = 3.5
        backButton.layer.shadowColor = UIColor.blackColor().CGColor
        backButton.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        backButton.setTitle("<", forState: UIControlState.Normal)
        backButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        backButton.addTarget(self, action: "backButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        
        // Add right bar button
        btLoadFromLocal.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btLoadFromLocal.backgroundColor = UIColor.MKColor.Blue
        btLoadFromLocal.cornerRadius = 20.0
        btLoadFromLocal.backgroundLayerCornerRadius = 20.0
        btLoadFromLocal.maskEnabled = false
        btLoadFromLocal.circleGrowRatioMax = 1.75
        btLoadFromLocal.rippleLocation = .Center
        btLoadFromLocal.aniDuration = 0.85
        btLoadFromLocal.layer.shadowOpacity = 0.75
        btLoadFromLocal.layer.shadowRadius = 3.5
        btLoadFromLocal.layer.shadowColor = UIColor.blackColor().CGColor
        btLoadFromLocal.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        btLoadFromLocal.setTitle("L", forState: UIControlState.Normal)
        btLoadFromLocal.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        btLoadFromLocal.addTarget(self, action: "loadButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: btLoadFromLocal)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
        
        framePickCollectionView.allowsSelection = true
    }
    
    func backButtonClick(sender:UIButton!){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func loadButtonClick(sender:UIButton!){
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            var popover:UIPopoverController?=nil
            popover=UIPopoverController(contentViewController: picker)
            popover!.presentPopoverFromRect(btLoadFromLocal.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func searchGG(placeName: String) {
        url = NSURL(string: "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&as_filetype=png&rsz=7&q=\(placeName)")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){ (response, go, error) -> Void in
            
            let go = NSJSONSerialization.JSONObjectWithData(go, options: NSJSONReadingOptions.AllowFragments, error: nil) as! [String:AnyObject]
            let responseData = go["responseData"] as! [String:AnyObject]
            
            self.result = responseData["results"] as! [[String:String]]
            self.framePickCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setting Collection View
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 7
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FrameCell", forIndexPath: indexPath) as! FramePickCollectionViewCell
        
        if isConnectedToNetwork() == true {
            // Config the cell
            // Set init image if drink image in cell doesn't load.
            var initImage = UIImage(named: "placeholder")
            //cell.drinkImageView.image = initImage
            cell.featureImageSizeOptional = initImage?.size
            
            // Pass data from google to the cell
            if self.result.count != 0 {
                let firstObject = self.result[indexPath.row]
                let firstURL = firstObject["unescapedUrl"]
                let url = NSURL(string: firstURL!)
                getDataFromUrl(url!) { data in
                    dispatch_async(dispatch_get_main_queue()) {
                        //println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                        cell.configureCellDisplayWithImageInfo(data!, nodeConstructionQueue: self.nodeConstructionQueue)
                    }
                }
                //let data = NSData(contentsOfURL: url!)
            }
            
        } else {
            let alertController = UIAlertController(title: "Network Error", message:
                "Please try connect to Internet again", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        return cell
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
    
    /*
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //Get device size
        var bounds: CGRect = UIScreen.mainScreen().bounds
        var dvWidth:CGFloat = bounds.size.width
        var dvHeight:CGFloat = bounds.size.height
        var cellSize = CGSize(width: dvWidth/2, height: 150)
        return cellSize
    }*/
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        framePickCollectionView.allowsSelection = false
        if self.result.count != 0 {
            let firstObject = self.result[indexPath.row]
            let firstURL = firstObject["unescapedUrl"]
            let url = NSURL(string: firstURL!)
            let data = NSData(contentsOfURL: url!)
            self.performSegueWithIdentifier("FramePickSegue", sender: data)
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FramePickSegue"){
            var editView:EditViewController = segue.destinationViewController as! EditViewController
            editView.imageData = sender as! NSData
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 202, height: 150)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // Config search bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        placeName = "\(colorPicked)+frame+\(searchBar.text)"
        self.navigationItem.title = colorPicked + " Frame" + " \(searchBar.text)"
        println(placeName)
        self.searchGG(placeName)
        self.view.endEditing(true)
    }
    
    func saveImageToLocal(indexPath: NSIndexPath) {
        let firstObject = self.result[indexPath.row]
        let firstURL = firstObject["unescapedUrl"]
        let url = NSURL(string: firstURL!)
        getDataFromUrl(url!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                //println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                let image = UIImage(data: data!)
                //Save it to the camera roll
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                let alertController = UIAlertController(title: "Success", message:
                    "Image saved", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            showActionSheet(gestureRecognizer)
            return
        }
    }
    
    func showActionSheet(gestureRecognizer: UILongPressGestureRecognizer) {
        var point:CGPoint = gestureRecognizer.locationInView(self.framePickCollectionView)
        var indexPath:NSIndexPath = self.framePickCollectionView.indexPathForItemAtPoint(point)!
        if indexPath.length == 0 {
            println("Couldn't find index path")
        } else {
            var cell:UICollectionViewCell = self.framePickCollectionView.cellForItemAtIndexPath(indexPath)!
            // 1
            let optionMenu = UIAlertController(title: nil, message: "Save Image", preferredStyle: .ActionSheet)
            
            // 2
            let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.saveImageToLocal(indexPath)
            })
            
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                println("Cancelled")
            })
            
            
            // 4
            optionMenu.addAction(saveAction)
            optionMenu.addAction(cancelAction)
            
            // 5
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        var data:NSData = UIImageJPEGRepresentation(image, 1.0)
        dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("FramePickSegue", sender: data)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return isReachable && !needsConnection
    }
}
