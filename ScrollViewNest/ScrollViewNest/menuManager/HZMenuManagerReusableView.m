//
//  HZMenuManagerReusableView.m
//  Pods
//
//  Created by mason on 2018/5/16.
//
//

#import "HZMenuManagerReusableView.h"

@interface HZMenuManagerReusableView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation HZMenuManagerReusableView

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}



@end
