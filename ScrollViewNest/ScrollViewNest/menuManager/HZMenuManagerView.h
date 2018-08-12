//
//  HZMenuManagerView.h
//  Pods
//
//  Created by mason on 2018/5/16.
//
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, HZPanDirection) {
    /** 方向 */
    HZPanDirectionNone,
    HZPanDirectionUp,
    HZPanDirectionDown,
    HZPanDirectionLeft,
    HZPanDirectionRight
};

@protocol HZMenuManagerViewDelegate<NSObject>

- (void)scrollWithY:(CGFloat) y panDirection:(HZPanDirection)panDirection animations:(BOOL) animations;
- (void)didSelectedItemWithKey:(NSString *)key;

@end

@interface HZMenuManagerView : UIView

@property (weak, nonatomic) id<HZMenuManagerViewDelegate>delegate;

@end
