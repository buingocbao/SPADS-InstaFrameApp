//
//  EditViewController.swift
//  SPADS-InstaFrameApp
//
//  Created by BBaoBao on 6/1/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit
import Photos
import AVFoundation


class EditViewController: UIViewController, settingViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    var imageData:NSData = NSData()
    @IBOutlet weak var btSetting: MKButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lbImageOne: UIImageView!
    @IBOutlet weak var lbImageTwo: UIImageView!
    @IBOutlet weak var lbImageThree: UIImageView!
    @IBOutlet weak var btSaveImage: MKButton!
    var pictureView:UIImageView = UIImageView()
    var popover:UIPopoverController?=nil
    var audioPlayer = AVAudioPlayer()
    var sdSpeedValue: Float = Float()
    var currentIndexPath: NSIndexPath = NSIndexPath()
    var selectedSound:String = "Telephone"
    var backButton:MKButton = MKButton()
    var userPick: Bool = Bool()
    var isRandom:Bool = false
    var count:Int = 0
    let anim = CAKeyframeAnimation(keyPath: "position")
    
    var picker:UIImagePickerController? = UIImagePickerController()
    
    var images:NSMutableArray! // <-- Array to hold the fetched images
    var totalImageCountNeeded:Int! // <-- The number of images to fetch
    
    let captureSession = AVCaptureSession()
    var stillImageOutput : AVCaptureStillImageOutput?
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Picker
        picker?.delegate = self
        
        // Setting button
        btSetting.layer.shadowOpacity = 0.75
        btSetting.layer.shadowRadius = 3.5
        btSetting.layer.shadowColor = UIColor.blackColor().CGColor
        btSetting.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        
        // Save Image button
        btSaveImage.layer.shadowOpacity = 0.75
        btSaveImage.layer.shadowRadius = 3.5
        btSaveImage.layer.shadowColor = UIColor.blackColor().CGColor
        btSaveImage.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        
        // Get 3 lastest photo from library
        fetchPhotos()
        assignPhotos()
        
        // 
        println(sdSpeedValue)
        println(currentIndexPath)
        println(selectedSound)
        
        // Back button on navigation bar
        addBackButton()
        
        //
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Enumerate devices and find a back-facing camera, then begin capture session

        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ==  AVAuthorizationStatus.Authorized
        {
            // Already Authorized
            let devices = AVCaptureDevice.devices()
            
            for device in devices
            {
                if (device.hasMediaType(AVMediaTypeVideo))
                {
                    if(device.position == AVCaptureDevicePosition.Front)
                    {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil
                        {
                            beginCaptureSession()
                        }
                    }
                }
            }
        }
        else
        {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true
                {
                    // User granted
                    let devices = AVCaptureDevice.devices()
                    
                    for device in devices
                    {
                        if (device.hasMediaType(AVMediaTypeVideo))
                        {
                            if(device.position == AVCaptureDevicePosition.Front)
                            {
                                self.captureDevice = device as? AVCaptureDevice
                                if self.captureDevice != nil
                                {
                                    self.beginCaptureSession()
                                }
                            }
                        }
                    }
                }
                else
                {
                    // User Rejected
                    let alertController = UIAlertController(title: "Camera Access Denied", message:
                        "Please gain camera access to continue.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.navigationController?.popViewControllerAnimated(true)
                }
            });
        }
    }
    
    func beginCaptureSession()
    {
        var error : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))
        
        if error != nil
        {
            NSLog("Can't add input")
        }
        else
        {
            // Create still image output and attach to session
            
            stillImageOutput = AVCaptureStillImageOutput()
            let outputSettings:Dictionary = [AVVideoCodecJPEG:AVVideoCodecKey]
            stillImageOutput?.outputSettings = outputSettings
            captureSession.addOutput(stillImageOutput)
            
            // Create preview layer from session and attach as sublayer
            captureSession.startRunning()
        }
    }
    
    func addBackButton() {
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
    }
    
    func backButtonClick(sender:UIButton!){
        self.pictureView.layer.removeAllAnimations()
        self.pictureView.removeFromSuperview()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func assignPhotos() {
        lbImageOne.image = images[0] as? UIImage
        lbImageTwo.image = images[1] as? UIImage
        lbImageThree.image = images[2] as? UIImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // When preparing for the segue, have viewController1 provide a closure for
        // onDataAvailable
        if (segue.identifier=="EmbedSegue") {
            var frameContentView:FrameContentViewController = segue.destinationViewController as! FrameContentViewController
            frameContentView.imageData = imageData
        }
        
        if let settingViewController = segue.destinationViewController as? SettingViewController {
            settingViewController.delegate = self
            /*
            settingViewController.onDataAvailable = {[weak self]
                (data, userPick, sdValue, selectedSound) in
                if let weakSelf = self {
                    weakSelf.doSomethingWithData(data, userPick: userPick, sdValue: sdValue, selectedSound: selectedSound, segue: segue)
                }
            }*/
        }
        
        if segue.identifier=="ImageViewSegue" {
            var imageViewController:ImageViewController = segue.destinationViewController as! ImageViewController
            imageViewController.image = (sender as? UIImage)!
        }
    
        if (segue.identifier=="SettingSegue") {
            var settingContentView:SettingViewController = segue.destinationViewController as! SettingViewController
            settingContentView.sdValueSpeed = sdSpeedValue
            settingContentView.currentSelectedIndexPath = currentIndexPath
            settingContentView.selectedSound = selectedSound
            settingContentView.isRandom = isRandom
        }
        
    }
    
    func settingViewControllerDidCancel(controller: SettingViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func settingViewControllerDidFinish(controller: SettingViewController, selectedIndexPath: NSIndexPath, userPick: Bool, sdValue: Float, selectedSound: String, isRandom: Bool) {
        self.dismissViewControllerAnimated(true, completion: nil)
        println(selectedIndexPath)
        println(userPick)
        println(sdValue)
        println(selectedSound)
        println(isRandom)
        self.sdSpeedValue = sdValue
        self.userPick = userPick
        self.isRandom = isRandom
        if selectedSound != "" {
            self.selectedSound = selectedSound
        }
        self.currentIndexPath = selectedIndexPath
        doSomethingWithData()
    }
    
    func doSomethingWithData() {
        if self.currentIndexPath != "" {
            pictureView.layer.removeAllAnimations()
            pictureView.removeFromSuperview()
            
            //Get device size
            var bounds: CGRect = UIScreen.mainScreen().bounds
            var dvWidth:CGFloat = bounds.size.width
            var dvHeight:CGFloat = bounds.size.height
            var randomX:CGFloat = CGFloat(arc4random_uniform(UInt32(containerView.frame.width-128)) + 1)
            var randomY:CGFloat = CGFloat(arc4random_uniform(UInt32(containerView.frame.height-128)) + 1)
            pictureView = UIImageView(frame: CGRect(x: randomX, y: randomY, width: 128, height: 128))
            if self.userPick == false {
                pictureView.image = UIImage(named: String(currentIndexPath.row))
            } else {
                if let testArray : AnyObject? = userDefault.objectForKey("pictureUserArray") {
                    if testArray != nil {
                        let array = testArray! as! [NSData]
                        pictureView.image = UIImage(data: array[currentIndexPath.row])
                    }
                }
            }
            
            containerView.addSubview(pictureView)
            containerView.bringSubviewToFront(pictureView)
            pictureView.userInteractionEnabled = true
            makeAnimation(randomX, ySource: randomY)
            //self.startAnimating(pictureView, sdValue: self.sdSpeedValue, rotate: false)
        }
    }
    /*
    func doSomethingWithData(data: NSIndexPath, userPick: Bool, sdValue: Float, selectedSound: String, segue: UIStoryboardSegue) {
        
        //sdSpeedValue = sdValue
        //currentIndexPath = data
        //self.selectedSound = selectedSound
        if selectedSound != "" {
            //self.selectedSound = selectedSound
            //println(self.selectedSound)
        }
        if self.currentIndexPath != "" {
            pictureView.removeFromSuperview()
            
            //Get device size
            var bounds: CGRect = UIScreen.mainScreen().bounds
            var dvWidth:CGFloat = bounds.size.width
            var dvHeight:CGFloat = bounds.size.height
            var randomX:CGFloat = CGFloat(arc4random_uniform(UInt32(containerView.frame.width-128)) + 1)
            var randomY:CGFloat = CGFloat(arc4random_uniform(UInt32(containerView.frame.height-128)) + 1)
            pictureView = UIImageView(frame: CGRect(x: randomX, y: randomY, width: 128, height: 128))
            if self.userPick == false {
                pictureView.image = UIImage(named: String(currentIndexPath.row))
            } else {
                if let testArray : AnyObject? = userDefault.objectForKey("pictureUserArray") {
                    if testArray != nil {
                        let array = testArray! as! [NSData]
                        pictureView.image = UIImage(data: array[currentIndexPath.row])
                    }
                }
            }
            
            containerView.addSubview(pictureView)
            containerView.bringSubviewToFront(pictureView)
            pictureView.userInteractionEnabled = true
            makeAnimation(randomX, ySource: randomY)
            //self.startAnimating(pictureView, sdValue: self.sdSpeedValue, rotate: true)
        }
        //Get device size
        //var bounds: CGRect = UIScreen.mainScreen().bounds
        //var dvWidth:CGFloat = bounds.size.width
        //var dvHeight:CGFloat = bounds.size.height
        //let xSourceRand = CGFloat(arc4random_uniform(UInt32(dvWidth)))
        //let ySourceRand = CGFloat(arc4random_uniform(UInt32(dvHeight)))
        //makeAnimation(xSourceRand, ySource: ySourceRand)
        /*
        // Do something with data
        //println("\(sdValue)")
        sdSpeedValue = sdValue
        println(sdSpeedValue)
        self.startAnimating(pictureView, sdValue: sdSpeedValue, rotate: true)
        currentIndexPath = data
        self.selectedSound = selectedSound
        println(sdSpeedValue)
        println(currentIndexPath)
        if selectedSound != "" {
            self.selectedSound = selectedSound
            println(self.selectedSound)
        }
        if data != "" {
            pictureView.removeFromSuperview()
            
            var randomX:CGFloat = CGFloat(arc4random_uniform(UInt32(containerView.frame.width-128)) + 1)
            var randomY:CGFloat = CGFloat(arc4random_uniform(UInt32(containerView.frame.height-128)) + 1)
            pictureView = UIImageView(frame: CGRect(x: randomX, y: randomY, width: 128, height: 128))
            if userPick == false {
                pictureView.image = UIImage(named: String(data.row))
            } else {
                if let testArray : AnyObject? = userDefault.objectForKey("pictureUserArray") {
                    if testArray != nil {
                        let array = testArray! as! [NSData]
                        pictureView.image = UIImage(data: array[data.row])
                    }
                }
            }
            
            containerView.addSubview(pictureView)
            containerView.bringSubviewToFront(pictureView)
            pictureView.userInteractionEnabled = true
            self.startAnimating(pictureView, sdValue: self.sdSpeedValue, rotate: true)
        }*/
    }*/
    func makeAnimation(xSource:CGFloat, ySource:CGFloat) {
        //Get device size
        var bounds: CGRect = UIScreen.mainScreen().bounds
        var dvWidth:CGFloat = bounds.size.width
        var dvHeight:CGFloat = bounds.size.height
        
        let direction = randomDirection()
        let xDesRand = CGFloat(arc4random_uniform(UInt32(dvWidth)))
        let yDesRand = CGFloat(arc4random_uniform(UInt32(self.containerView.frame.height)))
        //let xSourceRand = CGFloat(arc4random_uniform(UInt32(dvWidth)))
        //let ySourceRand = CGFloat(arc4random_uniform(UInt32(dvHeight)))
        
        switch direction {
        case "TOP": doAnimating(xSource, ySource: ySource, xDes: xDesRand, yDes: 0.0)
        case "LEFT": doAnimating(xSource, ySource: ySource, xDes: 0, yDes: yDesRand)
        case "RIGHT": doAnimating(xSource, ySource: ySource, xDes: dvWidth, yDes: yDesRand)
        case "BOTTOM": doAnimating(xSource, ySource: ySource, xDes: xDesRand, yDes: dvHeight)
        default: return
        }
        
        //recursiveAnimation()
    }
    func randomDirection() -> String {
        let randomDirection = Int(arc4random_uniform(4) + 1)
        switch randomDirection {
        case 1: return "TOP"
        case 2: return "LEFT"
        case 3: return "RIGHT"
        case 4: return "BOTTOM"
        default: return ""
        }
    }
    
    func doAnimating(xSource:CGFloat, ySource:CGFloat, xDes: CGFloat, yDes: CGFloat) {
        let fullRotation = CGFloat(M_PI * 2)
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
        var duration:Float
        //
        // now create a bezier path that defines our curve
        // the animation function needs the curve defined as a CGPath
        // but these are more difficult to work with, so instead
        // we'll create a UIBezierPath, and then create a
        // randomly create a value between 0.0 and 150.0
        let randomYOffset = CGFloat( arc4random_uniform(150))
        let path = UIBezierPath()
        if isRandom {
            duration = Float(arc4random_uniform(5)+1)
            // for every y-value on the bezier curve
            // add our random y offset so that each individual animation
            // will appear at a different y-position
            let xDesRand = CGFloat(arc4random_uniform(UInt32(UIScreen.mainScreen().bounds.size.height)))
            let yDesRand = CGFloat(arc4random_uniform(UInt32(self.containerView.frame.height)))
            path.moveToPoint(CGPoint(x: xSource,y: ySource))
            path.addCurveToPoint(CGPoint(x: xDesRand, y: yDesRand), controlPoint1: CGPoint(x: 136, y: 373 + randomYOffset), controlPoint2: CGPoint(x: 178, y: 110 + randomYOffset))
        } else {
            duration = sdSpeedValue
            // for every y-value on the bezier curve
            // add our random y offset so that each individual animation
            // will appear at a different y-position
            path.moveToPoint(CGPoint(x: xSource,y: ySource))
            path.addCurveToPoint(CGPoint(x: xDes, y: yDes), controlPoint1: CGPoint(x: 136, y: 373 + randomYOffset), controlPoint2: CGPoint(x: 178, y: 110 + randomYOffset))
        }
        
        // create the animation
        anim.delegate = self
        anim.path = path.CGPath
        anim.rotationMode = kCAAnimationRotateAuto
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        //anim.repeatCount = Float.infinity
        anim.duration = CFTimeInterval(duration)
        // add the animation
        pictureView.layer.addAnimation(anim, forKey: "animate position along path")
        
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if flag {
            let currentX = pictureView.layer.presentationLayer().frame.origin.x
            let currentY = pictureView.layer.presentationLayer().frame.origin.y
            makeAnimation(currentX, ySource: currentY)
        }
        
    }
    
    func startAnimating(pictureView: UIImageView, sdValue: Float, rotate: Bool) {
        if isRandom == false {
            UIView.animateWithDuration(1/NSTimeInterval(sdValue), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: {
                pictureView.frame = CGRect(x: self.randomDimension().0, y: self.randomDimension().1, width: 128, height: 128)
                if rotate == true {
                    pictureView.transform = CGAffineTransformMakeScale(-1, 1)
                } else {
                    pictureView.transform = CGAffineTransformMakeScale(1, -1)
                }
                }, completion: { (value: Bool) in
                    if rotate == false {
                        self.startAnimating(pictureView, sdValue: sdValue, rotate: true)
                    } else {
                        self.startAnimating(pictureView, sdValue: sdValue, rotate: false)
                    }
            })
        } else {
            var randomSpeed = arc4random_uniform(5) + 1
            UIView.animateWithDuration(1/NSTimeInterval(randomSpeed), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: {
                pictureView.frame = CGRect(x: self.randomDimension().0, y: self.randomDimension().1, width: 128, height: 128)
                if rotate == true {
                    pictureView.transform = CGAffineTransformMakeScale(-1, 1)
                } else {
                    pictureView.transform = CGAffineTransformMakeScale(1, -1)
                }
                }, completion: { (value: Bool) in
                    if rotate == false {
                        self.startAnimating(pictureView, sdValue: sdValue, rotate: true)
                    } else {
                        self.startAnimating(pictureView, sdValue: sdValue, rotate: false)
                    }
            })
        }
    }
    
    func randomDimension() -> (CGFloat, CGFloat) {
        
        //Get device size
        var bounds: CGRect = UIScreen.mainScreen().bounds
        var dvWidth:CGFloat = bounds.size.width
        var dvHeight:CGFloat = bounds.size.height
        
        var ctWidth:CGFloat = containerView.frame.width
        var ctHeight:CGFloat = containerView.frame.height
        
        var dimension:Int = Int(arc4random_uniform(4) + 1)
        switch dimension {
        case 1:
            return (CGFloat(arc4random_uniform(UInt32(dvWidth)) + 1) - 128, 0)
        case 2:
            return (CGFloat(arc4random_uniform(UInt32(dvWidth)) + 1) - 128, ctHeight - 128)
        case 3:
            return (0, CGFloat(arc4random_uniform(UInt32(ctHeight)) + 1) - 128)
        case 4:
            return (dvWidth - 128, CGFloat(arc4random_uniform(UInt32(ctHeight)) + 1) - 128)
        default: return (0,0)
        }
    }
    @IBAction func saveImageEvent(sender: AnyObject) {
        screenShotMethod()
        playCameraSound()
        fetchPhotos()
        assignPhotos()
    }
    
    func playCameraSound() {
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("CameraSound", ofType: "mp3")!)
        //println(alertSound)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func screenShotMethod() {
        
        //Create the UIImage
        UIGraphicsBeginImageContext(containerView.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        /*
        //Save it to the camera roll
        let currentDate = NSDate()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let destinationPath = documentsPath.stringByAppendingPathComponent("\(currentDate).jpg")
        UIImageJPEGRepresentation(image,1.0).writeToFile(destinationPath, atomically: true)
        */
    }
    
    func fetchPhotos () {
        images = NSMutableArray()
        totalImageCountNeeded = 3
        self.fetchPhotoAtIndexFromEnd(0)
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndexFromEnd(index:Int) {
        
        let imgManager = PHImageManager.defaultManager()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            
            // If the fetch result isn't empty,
            // proceed with the image request
            if fetchResult.count > 0 {
                // Perform the image request
                imgManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    // Add the returned image to your array
                    self.images.addObject(image)
                    
                    // If you haven't already reached the first
                    // index of the fetch result and if you haven't
                    // already stored all of the images you need,
                    // perform the fetch request again with an
                    // incremented index
                    if index + 1 < fetchResult.count && self.images.count < self.totalImageCountNeeded {
                        self.fetchPhotoAtIndexFromEnd(index + 1)
                    } else {
                        // Else you have completed creating your array
                        //println("Completed array: \(self.images)")
                    }
                })
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        for touch: AnyObject in touches {
            if (touch.view == lbImageOne || touch.view == lbImageTwo || touch.view == lbImageThree) {
                openGallary()
                
            }
            
            var t: UITouch = touch as! UITouch
            let location = t.locationInView(self.view)
            
            if self.pictureView.layer.presentationLayer() != nil {
                if let hitTest = self.pictureView.layer.presentationLayer().hitTest(location) {
                    println("Layer Touch")
                    count++
                    if count == 3 {
                        count = 0
                        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.pictureView.alpha = 0
                            }, completion: { finish in
                                UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                    self.pictureView.alpha = 1
                                    }, completion: nil)
                        })
                    }
                    playImageSound()
                    captureByFrontCamera()
                    fetchPhotos()
                    assignPhotos()
                }
            }
            
            
            self.view.rippleFill(location, color: UIColor.MKColor.Blue)
            
            /*
            if (touch.view == pictureView) {
                //self.pictureView.stopAnimating()
                //println("Touch")
                count++
                if count == 3 {
                    count = 0
                    UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.pictureView.alpha = 0
                        }, completion: { finish in
                            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                self.pictureView.alpha = 1
                                }, completion: nil)
                    })
                }
                playImageSound()
                captureByFrontCamera()
                fetchPhotos()
                assignPhotos()
            }*/
            
            
            /*
            if CGPathContainsPoint(anim.path, nil, location, false) {
                //println("Layer Touch")
                count++
                if count == 3 {
                    count = 0
                    UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.pictureView.alpha = 0
                        }, completion: { finish in
                            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                self.pictureView.alpha = 1
                                }, completion: nil)
                    })
                }
                playImageSound()
                captureByFrontCamera()
                fetchPhotos()
                assignPhotos()
            }*/
            
        }
    }
    
    func captureByFrontCamera() {
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
        {
            // Get single image as JPEG and store to photo roll
            
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection)
                {
                    (imageSampleBuffer : CMSampleBuffer!, _) in
                    
                    let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    var pickedImage: UIImage = UIImage(data: imageDataJpeg)!
                    var imageContent:UIImageView = UIImageView(image: pickedImage)
                    var frameContentView = UIImageView(image: UIImage(data: self.imageData))
                    frameContentView.frame = CGRect(x: imageContent.frame.origin.x, y: imageContent.frame.origin.y, width: imageContent.frame.width, height: imageContent.frame.height)
                    imageContent.addSubview(frameContentView)
                    //var finalImage:UIImage = imageContent.image!
                    //UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
                    
                    UIGraphicsBeginImageContext(imageContent.frame.size)
                    imageContent.layer.renderInContext(UIGraphicsGetCurrentContext())
                    var finalImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
            }
        }
    }
    
    func playImageSound() {
        if selectedSound.hasSuffix(".wav") {
            var soundURL:NSURL = NSURL(string: selectedSound)!
            var alertSound = soundURL
            
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } else {
            var string = selectedSound.stringByReplacingOccurrencesOfString(".mp3", withString: "", options: .LiteralSearch, range: nil)
            var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(string, ofType: "mp3")!)
            
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    func stopAnimating() {
        var layer = pictureView
        var frame = layer.frame
        //println(frame)
        pictureView.removeFromSuperview()
        layer.layer.removeAllAnimations()
        pictureView = layer
        //println(layer)
        //println(pictureView)
        containerView.addSubview(pictureView)
    }
    
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: picker!)
            popover!.presentPopoverFromRect(lbImageTwo.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        /*
        //Get device size
        var bounds: CGRect = UIScreen.mainScreen().bounds
        var dvWidth:CGFloat = bounds.size.width
        var dvHeight:CGFloat = bounds.size.height
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: dvWidth, height: dvHeight)
        imageView.backgroundColor = UIColor.whiteColor()
        view.addSubview(imageView)
        view.bringSubviewToFront(imageView)
        */
        dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("ImageViewSegue", sender: image)
    }
}
