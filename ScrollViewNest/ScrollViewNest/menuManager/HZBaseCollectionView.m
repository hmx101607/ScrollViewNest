//
//  HZBaseCollectionView.m
//  Pods
//
//  Created by mason on 2018/5/17.
//
//

#import "HZBaseCollectionView.h"

@implementation HZBaseCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        if ([self.delegate respondsToSelector:@selector(fetchContainerViewWithStartY)]) {
            CGFloat startY = [self.baseCollectionViewdelegate fetchContainerViewWithStartY];
            CGPoint point = [recognizer translationInView:recognizer.view];//处理方向
            /*
             1.外层view是否在最顶部即frame的y值是否为0(在停止时，y值只有三种情况：0， 150， ScreenHeight-49)
             2.scrollview的偏移值 ( contentOffset.y < 0 偏下  >0 偏上)
             3.滑动方向：向上还是向下 ( point.y > 0:向下， point.y > 0:向上)
             */
            if (startY <= 20) {
                if (point.y > 0) {//向下
                    if (self.contentOffset.y > 0) {// <0 偏下（目前的设置，不可能出现）   >0 偏上
                        return YES;
                    } else {
                        return NO;
                    }
                } else {
                    return YES;
                }
            } else {
                return NO;
            }
        }
    }
    
    return YES;
}



@end
