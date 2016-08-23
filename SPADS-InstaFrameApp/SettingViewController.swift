//
//  SettingViewController.swift
//  SPADS-InstaFrameApp
//
//  Created by BBaoBao on 6/1/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit
import AVFoundation

protocol settingViewControllerDelegate {
    //func sendData(selectedIndexPath: NSIndexPath, sdValue: Float, selectedSound: String)
    func settingViewControllerDidCancel(controller: SettingViewController)
    
    func settingViewControllerDidFinish(controller: SettingViewController, selectedIndexPath: NSIndexPath, userPick: Bool, sdValue: Float, selectedSound: String, isRandom: Bool)
}

class SettingViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    @IBOutlet weak var btExit: MKButton!
    @IBOutlet weak var btOK: MKButton!
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    @IBOutlet weak var sdSpeed: UISlider!
    @IBOutlet weak var tableViewSound: UITableView!
    @IBOutlet weak var btRecord: MKButton!
    @IBOutlet weak var smRandom: UISwitch!
    
    var sdValueSpeed: Float = Float()
    
    var onDataAvailable : ((data: NSIndexPath, userPick:Bool, sdValue: Float, selectedSound: String) -> ())?
    
    var selectedIndexPath:NSIndexPath!
    
    var currentSelectedIndexPath:NSIndexPath = NSIndexPath()
    
    var pictureArray = ["0","1","2","3","4","5","6"]
    
    var pictureArray2:[NSData] = []
    
    var wavArray:[AnyObject]!
    
    var suggestSound = ["1.mp3","2.mp3","3.mp3","4.mp3","5.mp3"]
    
    var audioPlayer = AVAudioPlayer()
    
    var refreshControl: UIRefreshControl!
    
    var selectedSound:String = ""
    
    var delegate:settingViewControllerDelegate?
    
    var picturePicker:UIImagePickerController? = UIImagePickerController()

    var userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var userPick:Bool = false
    
    var isRandom:Bool = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var delegate: settingViewControllerDelegate?
        
        pictureCollectionView.delegate = self
        pictureCollectionView.dataSource = self
        tableViewSound.delegate = self
        tableViewSound.dataSource = self
        
        // Exit Button
        btExit.cornerRadius = 30.0
        btExit.backgroundLayerCornerRadius = 30.0
        btExit.maskEnabled = false
        btExit.circleGrowRatioMax = 1.75
        btExit.rippleLocation = .Center
        btExit.aniDuration = 0.85
        self.view.bringSubviewToFront(btExit)
        
        btExit.layer.shadowOpacity = 0.75
        btExit.layer.shadowRadius = 3.5
        btExit.layer.shadowColor = UIColor.blackColor().CGColor
        btExit.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        
        // OK Button
        btOK.cornerRadius = 30.0
        btOK.backgroundLayerCornerRadius = 30.0
        btOK.maskEnabled = false
        btOK.circleGrowRatioMax = 1.75
        btOK.rippleLocation = .Center
        btOK.aniDuration = 0.85
        self.view.bringSubviewToFront(btOK)
        
        btOK.layer.shadowOpacity = 0.75
        btOK.layer.shadowRadius = 3.5
        btOK.layer.shadowColor = UIColor.blackColor().CGColor
        btOK.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        
        // Record button
        self.view.bringSubviewToFront(btOK)
        btRecord.backgroundColor = UIColor.MKColor.Red
        btRecord.layer.shadowOpacity = 0.75
        btRecord.layer.shadowRadius = 3.5
        btRecord.layer.shadowColor = UIColor.blackColor().CGColor
        btRecord.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        
        // Slider config
        sdSpeed.minimumValue = 1.0
        sdSpeed.maximumValue = 5.0
        //sdSpeed.value = Float(arc4random_uniform(5) + 1)
        //println(sdValueSpeed)
        sdSpeed.value = sdValueSpeed
        if isRandom {
            sdSpeed.enabled = false
        }
        smRandom.on = isRandom
        
        // Tableview config
        tableViewConfig()
        
        // Config table view
        
        getSoundFiles()
        
        // Config Refresh Control
        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: Selector("soundRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.tableViewSound?.addSubview(refreshControl)
        
        // Load local array
        if let testArray : AnyObject? = userDefault.objectForKey("pictureUserArray") {
            if testArray != nil {
                pictureArray2 = testArray! as! [NSData]
            }
        }
        //println(pictureArray2)
    }
    
    func getSoundFiles() {
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // now lets get the directory contents (including folders)
        if let directoryContents =  NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsUrl.path!, error: nil) {
            //println(directoryContents)
        }
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            //println(directoryUrls)
            self.wavArray = directoryUrls
            //println(self.wavArray)
            let wavFiles = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "wav" }
            
            //println("WAV FILES:\n" + wavFiles.description)
        }
    }
    
    func soundRefresh() {
        getSoundFiles()
        tableViewSound.reloadData()
        self.refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableViewConfig() {
        // Config Tableview
        println(sdValueSpeed)
        println(currentSelectedIndexPath)
        tableViewSound.separatorColor = UIColor.whiteColor()
    }
    
    @IBAction func btExitEvent(sender: AnyObject) {
        //self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        self.delegate!.settingViewControllerDidCancel(self)
    }
    
    @IBAction func btOKEvent(sender: AnyObject) {
        if selectedIndexPath != nil {
            //sendData(self.selectedIndexPath, userPick: userPick, sdValue: self.sdSpeed.value, selectedSound: selectedSound)
            self.delegate!.settingViewControllerDidFinish(self, selectedIndexPath: self.selectedIndexPath, userPick: userPick, sdValue: self.sdSpeed.value, selectedSound: selectedSound, isRandom: self.smRandom.on)
        } else {
            //sendData(self.currentSelectedIndexPath, userPick: userPick, sdValue:self.sdValueSpeed, selectedSound: selectedSound)
            if self.currentSelectedIndexPath.length != 0 {
                self.delegate!.settingViewControllerDidFinish(self, selectedIndexPath: currentSelectedIndexPath, userPick: userPick, sdValue: self.sdValueSpeed, selectedSound: selectedSound, isRandom: self.smRandom.on)
            }
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }

    
    // MARK: Setting Collection View
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        if section == 0 {
            return pictureArray.count
        } else if section == 1 {
            return pictureArray2.count
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureCell", forIndexPath: indexPath) as! PictureCollectionViewCell
        
        if indexPath.section == 0 {
            // Config the cell
            cell.imagePicture.image = UIImage(named: String(indexPath.row))
            cell.imagePicture.userInteractionEnabled = false
            if (self.selectedIndexPath != nil && indexPath.compare(self.selectedIndexPath) == NSComparisonResult.OrderedSame) {
                cell.backgroundColor = UIColor.whiteColor()
            } else {
                cell.backgroundColor = UIColor.clearColor()
            }
        }
        if indexPath.section == 1 {
            dispatch_async(dispatch_get_main_queue()) {
                // Config the cell
                // Long press event
                var longPress = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
                longPress.minimumPressDuration = 0.5
                longPress.delegate = self
                cell.addGestureRecognizer(longPress)
                //cell.imagePicture.image = UIImage(named: String(indexPath.row))
                var image = UIImage(data: self.pictureArray2[indexPath.row])
                cell.imagePicture.image = image
                cell.imagePicture.userInteractionEnabled = false
                if (self.selectedIndexPath != nil && indexPath.compare(self.selectedIndexPath) == NSComparisonResult.OrderedSame) {
                    cell.backgroundColor = UIColor.whiteColor()
                } else {
                    cell.backgroundColor = UIColor.clearColor()
                }}
        }
        
        if indexPath.section == 2 {
            // Config the cell
            cell.imagePicture.image = UIImage(named: "Add")
            cell.imagePicture.userInteractionEnabled = true
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var cellSize = CGSize(width: 80, height: 80)
        return cellSize
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            var indexPaths:NSMutableArray = NSMutableArray(array: [indexPath])
            userPick = false
            
            if ((self.selectedIndexPath) != nil) {
                if (indexPath.compare(self.selectedIndexPath) == NSComparisonResult.OrderedSame) {
                    self.selectedIndexPath = nil
                } else {
                    indexPaths.addObject(self.selectedIndexPath)
                    self.selectedIndexPath = indexPath
                }
            } else {
                self.selectedIndexPath = indexPath
            }
            collectionView.reloadItemsAtIndexPaths(indexPaths as [AnyObject])
            //println(self.selectedIndexPath.row)
        }
        
        if indexPath.section == 1 {
            var indexPaths:NSMutableArray = NSMutableArray(array: [indexPath])
            userPick = true
            
            if ((self.selectedIndexPath) != nil) {
                if (indexPath.compare(self.selectedIndexPath) == NSComparisonResult.OrderedSame) {
                    self.selectedIndexPath = nil
                } else {
                    indexPaths.addObject(self.selectedIndexPath)
                    self.selectedIndexPath = indexPath
                }
            } else {
                self.selectedIndexPath = indexPath
            }
            collectionView.reloadItemsAtIndexPaths(indexPaths as [AnyObject])
            //println(self.selectedIndexPath.row)
        }
        
        if indexPath.section == 2 {
            picturePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picturePicker?.delegate = self
            self.presentViewController(picturePicker!, animated: true, completion:nil)
        }
    }
    
    func saveImageToLocal() {
        userDefault.setObject(pictureArray2, forKey: "pictureUserArray")
        userDefault.synchronize()
        pictureCollectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = nil
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func sendData(data: NSIndexPath, userPick: Bool, sdValue: Float, selectedSound: String) {
        // Whenever you want to send data back to viewController1, check
        // if the closure is implemented and then call it if it is
        if selectedIndexPath != nil {
            self.onDataAvailable?(data: data, userPick: userPick, sdValue: sdValue, selectedSound: selectedSound)
        }
    }
    
    // MARK: Table view config
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return suggestSound.count
        } else {
            return wavArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SoundCell", forIndexPath: indexPath) as! UITableViewCell
        
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.text = String(suggestSound[indexPath.row])
            cell.textLabel?.textColor = UIColor.whiteColor()
        }
        
        if indexPath.section == 1 {
            let wavFiles = wavArray.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == "wav" }
            //println("WAV FILES:\n" + wavFiles.description)
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.text = String(wavFiles[indexPath.row])
            cell.textLabel?.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionHeaderView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        sectionHeaderView.backgroundColor = UIColor.MKColor.LightGreen
        
        var headerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: sectionHeaderView.frame.size.width, height: 20))
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.font = UIFont(name: "", size: 20)
        sectionHeaderView.addSubview(headerLabel)
        
        if section == 0 {
            headerLabel.text = "Sound Suggestion"
            return sectionHeaderView
        }
        if section == 1 {
            headerLabel.text = "User Sound"
            return sectionHeaderView
        }
        return sectionHeaderView

    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            playSound(suggestSound, indexPath: indexPath)
            //println(suggestSound[indexPath.row])
            selectedSound = suggestSound[indexPath.row]
            //println(selectedSound)
        } else {
            playSound(wavArray, indexPath: indexPath)
            //println(wavArray[indexPath.row])
            selectedSound = wavArray[indexPath.row].absoluteString!!
            //println(selectedSound)
        }
    }
    
    // called when a row deletion action is confirmed
    func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            if indexPath.section == 1{
                switch editingStyle {
                case .Delete:
                    // remove the deleted item from the model
                    NSFileManager.defaultManager().removeItemAtURL(wavArray[indexPath.row] as! NSURL, error: nil)
                    wavArray.removeAtIndex(indexPath.row)
                    //println(wavArray.count)
                    //tableViewSound.reloadData()
                    
                    // remove the deleted item from the `UITableView`
                    self.tableViewSound.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                default:
                    return
                }
            }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    func playSound(array:[AnyObject], indexPath: NSIndexPath) {
        if indexPath.section == 0{
            var soundString:String = (array[indexPath.row] as! String)
            soundString = soundString.stringByReplacingOccurrencesOfString(".mp3", withString: "", options: .LiteralSearch, range: nil)
            var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(soundString, ofType: "mp3")!)
            //println(alertSound)
            
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        
        else {
            var soundURL:NSURL = (array[indexPath.row] as! NSURL)
            var alertSound = soundURL
            //println(soundURL)
            
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    @IBAction func sdSpeedValueChange(sender: AnyObject) {
        sdValueSpeed = sdSpeed.value
        println(sdValueSpeed)
    }

    @IBAction func btRecord(sender: AnyObject) {
        var bounds: CGRect = UIScreen.mainScreen().bounds
        var dvWidth:CGFloat = bounds.size.width
        var dvHeight:CGFloat = bounds.size.height
        
        var popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("RecordViewController") as! UIViewController
        var nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        var popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(500,600)
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRectMake(dvWidth/2,btRecord.frame.origin.y,1,1)
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Ended {
            showActionSheet(gestureRecognizer)
            return
        }
    }
    
    func showActionSheet(gestureRecognizer: UILongPressGestureRecognizer) {
        var point:CGPoint = gestureRecognizer.locationInView(self.pictureCollectionView)
        var indexPath:NSIndexPath = self.pictureCollectionView.indexPathForItemAtPoint(point)!
        if indexPath.length == 0 {
            println("Couldn't find index path")
        } else {
            var cell:UICollectionViewCell = self.pictureCollectionView.cellForItemAtIndexPath(indexPath)!
            // 1
            let optionMenu = UIAlertController(title: nil, message: "Delete Picture", preferredStyle: .ActionSheet)
            
            // 2
            let saveAction = UIAlertAction(title: "Delete", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                // Delete
                self.pictureArray2.removeAtIndex(indexPath.row)
                self.userDefault.setObject(self.pictureArray2, forKey: "pictureUserArray")
                self.userDefault.synchronize()
                self.pictureCollectionView.reloadData()
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
        var imageData:NSData = UIImagePNGRepresentation(image)
        self.pictureArray2.append(imageData)
        self.saveImageToLocal()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SettingSegue"){
            var editView:EditViewController = segue.destinationViewController as! EditViewController
            editView.sdSpeedValue = sender as! Float
        }
    }
    
    @IBAction func smRandomEvent(sender: AnyObject) {
        isRandom = smRandom.on
        if smRandom.on {
            sdSpeed.enabled = false
        } else {
            sdSpeed.enabled = true
        }
        
    }
}
