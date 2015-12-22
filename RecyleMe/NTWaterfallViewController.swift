//
//  ViewController.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import UIKit

let waterfallViewCellIdentify = "waterfallViewCellIdentify"

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate{
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        let transition = NTTransition()
        transition.presenting = operation == .Pop
        return  transition
    }
}

class ImageLoader {
    
    let cache = NSCache()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(urlString: String, completionHandler:(image: UIImage?, url: String) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
            let data: NSData? = self.cache.objectForKey(urlString) as? NSData
            
            if let goodData = data {
                let image = UIImage(data: goodData)
                dispatch_async(dispatch_get_main_queue(), {() in
                    completionHandler(image: image, url: urlString)
                })
                return
            }
            
            let downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error != nil) {
                    completionHandler(image: nil, url: urlString)
                    return
                }
                
                if let data = data {
                    let image = UIImage(data: data)
                    self.cache.setObject(data, forKey: urlString)
                    dispatch_async(dispatch_get_main_queue(), {() in
                        completionHandler(image: image, url: urlString)
                    })
                    return
                }
                
            })
            downloadTask.resume()
        })
        
    }
}


class NTWaterfallViewController:UICollectionViewController,CHTCollectionViewDelegateWaterfallLayout, NTTransitionProtocol, NTWaterFallViewControllerProtocol{
//    class var sharedInstance: NSInteger = 0 Are u kidding me?
    var imageNameList : Array <NSString> = []
    var azureImages: [UIImage] = []
    let delegateHolder = NavigationControllerDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController!.delegate = delegateHolder
        self.view.backgroundColor = UIColor.yellowColor()
        
//        var index = 0
//        while(index<14){
//            let imageName = NSString(format: "%d.jpg", index)
//            imageNameList.append(imageName)
//            index++
//        }
        let collection:UICollectionView = self.collectionView!;
        collection.frame = screenBounds
        collection.setCollectionViewLayout(CHTCollectionViewWaterfallLayout(), animated: false)
        collection.backgroundColor = UIColor.grayColor()
        collection.registerClass(NTWaterfallViewCell.self, forCellWithReuseIdentifier: waterfallViewCellIdentify)
        
        invokeImageData(collection)
        
        


    }
    
    func invokeImageData(collection:UICollectionView )
    {
        
        
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: "http://recyclemeapi.azurewebsites.net/odata/Item/?$filter=IsDeleted%20eq%20false%20and%20Status%20ne%201&$orderby=ModifiedDate%20desc&$expand=ItemImages,Owner,ItemCommented,ItemCommented/Commenter,ItemUserFollowers")!
        
        let dataTask = session.dataTaskWithURL(url) { (data,response, error) -> Void in
            
            do
            {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                
                
                let parentResult = jsonData.objectForKey("value") as! NSArray
                for item in parentResult
                {
                    let image = item.objectForKey("ItemImages") as! NSArray
                    for path in image
                    {
                        let trackName: String = self.getVaule(path as! NSDictionary, fieldName: "Path")!
                        //print(trackName)
                        let aString = "https://recyclemeblob.blob.core.windows.net/images/"
                        let replaced = trackName.stringByReplacingOccurrencesOfString(aString, withString: "")
                         print(replaced)
                        self.imageNameList.append(replaced)
                        
                        ImageLoader.sharedLoader.imageForUrl(trackName, completionHandler:{(image: UIImage?, url: String) in
                           // self.myImage.image = image!
                            self.azureImages.append(image!)
                            if(self.azureImages.count == parentResult.count){
                                        collection.reloadData()
                            }
                        })
                    }
                }
                
             
                
            }
            catch
            {
                print("Error: \(error)")
            }
        }
        
        dataTask.resume()
        
    }
    
    func getVaule<T>(jsonData:NSDictionary, fieldName: String) -> T?
    {
        if let value: T? = jsonData.objectForKey(fieldName) as? T?
        {
            return value
        }
        else
        {
            return nil
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        let image:UIImage! = self.azureImages[indexPath.row] //UIImage(named: self.imageNameList[indexPath.row] as String)
        let imageHeight = image.size.height*gridWidth/image.size.width
        print(imageHeight);
        return CGSizeMake(gridWidth, imageHeight)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let collectionCell: NTWaterfallViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(waterfallViewCellIdentify, forIndexPath: indexPath) as! NTWaterfallViewCell
        //collectionCell.imageName = self.imageNameList[indexPath.row] as String
        collectionCell.azureImages = self.azureImages[indexPath.row] 
        collectionCell.setNeedsLayout()
        return collectionCell;
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imageNameList.count;
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let pageViewController =
        NTHorizontalPageViewController(collectionViewLayout: pageViewControllerLayout(), currentIndexPath:indexPath)
        pageViewController.imageNameList = imageNameList
        pageViewController.azureImages = self.azureImages;
        collectionView.setToIndexPath(indexPath)
        navigationController!.pushViewController(pageViewController, animated: true)
    }
    
    func pageViewControllerLayout () -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let itemSize  = self.navigationController!.navigationBarHidden ?
        CGSizeMake(screenWidth, screenHeight+20) : CGSizeMake(screenWidth, screenHeight-navigationHeaderAndStatusbarHeight)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        return flowLayout
    }
    
    func viewWillAppearWithPageIndex(pageIndex : NSInteger) {
        var position : UICollectionViewScrollPosition =
        UICollectionViewScrollPosition.CenteredHorizontally.intersect(.CenteredVertically)
        let image:UIImage! = self.azureImages[pageIndex]//UIImage(named: self.imageNameList[pageIndex] as String)
        let imageHeight = image.size.height*gridWidth/image.size.width
        if imageHeight > 400 {//whatever you like, it's the max value for height of image
           position = .Top
        }
        let currentIndexPath = NSIndexPath(forRow: pageIndex, inSection: 0)
        let collectionView = self.collectionView!;
        collectionView.setToIndexPath(currentIndexPath)
        if pageIndex<2{
            collectionView.setContentOffset(CGPointZero, animated: false)
        }else{
            collectionView.scrollToItemAtIndexPath(currentIndexPath, atScrollPosition: position, animated: false)
        }
    }
    
    func transitionCollectionView() -> UICollectionView!{
        return collectionView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

