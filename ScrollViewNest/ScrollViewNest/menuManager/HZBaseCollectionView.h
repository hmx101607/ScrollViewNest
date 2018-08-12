//
//  HZBaseCollectionView.h
//  Pods
//
//  Created by mason on 2018/5/17.
//
//

#import <UIKit/UIKit.h>

@protocol HZBaseCollectionViewDelegate<NSObject>

- (CGFloat)fetchContainerViewWithStartY;

@end

@interface HZBaseCollectionView : UICollectionView

@property (weak, nonatomic) id<HZBaseCollectionViewDelegate>baseCollectionViewdelegate;

@end
