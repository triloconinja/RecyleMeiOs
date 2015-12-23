import Foundation
import UIKit

@objc protocol NTTransitionProtocol{
    func transitionCollectionView() -> UICollectionView!
}

@objc protocol NTTansitionWaterfallGridViewProtocol{
    func snapShotForTransition() -> UIView!
    
}

@objc protocol NTWaterFallViewControllerProtocol : NTTransitionProtocol{
    func viewWillAppearWithPageIndex(pageIndex : NSInteger)
    
}

@objc protocol NTHorizontalPageViewControllerProtocol : NTTransitionProtocol{
    func pageViewCellScrollViewContentOffset() -> CGPoint
}

