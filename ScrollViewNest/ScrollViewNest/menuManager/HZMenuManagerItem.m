//
//  HZMenuManagerItem.m
//  Pods
//
//  Created by mason on 2018/5/16.
//
//

#import "HZMenuManagerItem.h"

@interface HZMenuManagerItem ()


@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation HZMenuManagerItem


- (void)setContentDictionary:(NSDictionary *)contentDictionary {
    _contentDictionary = contentDictionary;
    self.iconImageView.image = [UIImage imageNamed:contentDictionary[@"icon"]];
    self.titleLabel.text = contentDictionary[@"title"];
    
}

- (UIImageView *)logoImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.iconImageView.frame];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"icon_river_header_background"];
    return imageView;
}

- (CGRect) imageViewFrame {
    CGRect frame = [self convertRect:self.iconImageView.frame toView:self.superview.superview];
    return CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
}


@end
