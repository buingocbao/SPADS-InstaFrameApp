//
//  ColorPickerViewController.swift
//  SPADS-InstaFrameApp
//
//  Created by BBaoBao on 6/1/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    let nodeConstructionQueue = NSOperationQueue()
    
    let colorPickerArray = [UIColor.MKColor.Blue, UIColor.MKColor.Red, UIColor.MKColor.Yellow, UIColor.MKColor.Green, UIColor.blackColor()]
    let colorDesArray = ["Blue", "Red", "Yellow", "Green", "Black"]
    
    // MARK: View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Set delegate and DataSource
        colorCollectionView!.dataSource = self
        colorCollectionView!.delegate = self
        
        // Show scroll bar
        colorCollectionView.flashScrollIndicators()
        
        // Transparent navigation bar
        //let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        //bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        //bar.shadowImage = UIImage()
        //bar.backgroundColor = UIColor.clearColor()
        //bar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
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
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCell", forIndexPath: indexPath) as! ColorPickerCollectionViewCell
        
        // Configure the cell
        var color = colorPickerArray[indexPath.row]
        var des = colorDesArray[indexPath.row]
        cell.imageView.backgroundColor = color
        cell.labelView.textColor = UIColor.whiteColor()
        cell.labelView.text = des
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //Get device size
        var bounds: CGRect = UIScreen.mainScreen().bounds
        var dvWidth:CGFloat = bounds.size.width
        var dvHeight:CGFloat = bounds.size.height
        var cellSize = CGSize(width: dvWidth, height: 150)
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var colorPick:String = colorDesArray[indexPath.row]
        self.performSegueWithIdentifier("ColorPickSegue", sender: colorPick)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ColorPickSegue"){
            var searchView:SearchViewController = segue.destinationViewController as! SearchViewController
            searchView.colorPicked = sender as! String
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
