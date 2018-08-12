//
//  HZHomeMapViewController.m
//  Pods
//
//  Created by mason on 2018/5/17.
//
//

#import "HZHomeMapViewController.h"
#import "HZMenuManagerView.h"

@protocol HZPanMenuViewDelegate<NSObject>

- (void)movePoint:(CGPoint)point direction:(HZPanDirection)direction;
- (void)moveEndPoint:(CGPoint)point direction:(HZPanDirection)direction;

@end

@interface HZPanMenuView : UIImageView

@property (weak, nonatomic) id<HZPanMenuViewDelegate>delegate;

@end

@implementation HZPanMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"home_up"];
    }
    return self;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    CGPoint prevLocation = [touch previousLocationInView:self.superview];
    
    self.center = CGPointMake(self.center.x, point.y);
    HZPanDirection direction = [self moveDirectionWithCurrentPoint:point prevPoint:prevLocation];
    if ([self.delegate respondsToSelector:@selector(movePoint:direction:)]) {
        [self.delegate movePoint:point direction:direction];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    CGPoint prevLocation = [touch previousLocationInView:self.superview];
    self.center = CGPointMake(self.center.x, point.y);
    
    HZPanDirection direction = [self moveDirectionWithCurrentPoint:point prevPoint:prevLocation];
    if ([self.delegate respondsToSelector:@selector(movePoint:direction:)]) {
        [self.delegate moveEndPoint:point direction:direction];
    }
}

- (HZPanDirection) moveDirectionWithCurrentPoint:(CGPoint)currentPoint prevPoint:(CGPoint)prevPoint {
    if (currentPoint.y - prevPoint.y > 0) {
        return HZPanDirectionDown;
    } else {
        return HZPanDirectionUp;
    }
}

@end


@interface HZHomeMapViewController ()
<
HZPanMenuViewDelegate,
HZMenuManagerViewDelegate
>
/** <##> */
@property (strong, nonatomic) HZMenuManagerView *menuManagerView;
/** <##> */
@property (strong, nonatomic) HZPanMenuView *panMenuView;
/** <##> */
@property (strong, nonatomic) UIView *statusView;

@end

@implementation HZHomeMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - setup UI
- (void) setupView {
    if ([UIDevice currentDevice].systemVersion.doubleValue < 11) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    HZMenuManagerView *menuManagerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HZMenuManagerView class]) owner:nil options:nil] firstObject];

    menuManagerView.frame = CGRectMake(0, SCREEN_HEIGHT - 49.f, SCREEN_WIDTH, SCREEN_HEIGHT - 69.f);
    menuManagerView.delegate = self;
    [self.view addSubview:menuManagerView];
    self.menuManagerView = menuManagerView;
    
    HZPanMenuView *panMenuView = [HZPanMenuView new];
    panMenuView.frame = CGRectMake(SCREEN_WIDTH/2 - 20.f, SCREEN_HEIGHT - 129.f, 40.f, 40.f);
    panMenuView.layer.cornerRadius = panMenuView.frame.size.width / 2;
    panMenuView.delegate = self;
    [self.view addSubview:panMenuView];
    self.panMenuView = panMenuView;
    
    UIView *statusView = [UIView new];
    statusView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20.f);
    statusView.backgroundColor = [UIColor whiteColor];
    statusView.alpha = 0;
    [self.view addSubview:statusView];
    self.statusView = statusView;
    
}

#pragma mark - Delegate HZPanMenuViewDelegate
- (void)movePoint:(CGPoint)point direction:(HZPanDirection)direction {
    CGRect frame = CGRectMake(0, point.y + 50.f, SCREEN_WIDTH, SCREEN_HEIGHT - 69.f);
    self.menuManagerView.frame = frame;
    CGFloat scale = point.y / (SCREEN_HEIGHT - 69.f);
    self.panMenuView.transform = CGAffineTransformMakeScale(scale, scale);
    self.panMenuView.alpha = scale;
    self.statusView.alpha = 1-scale;
}

- (void)moveEndPoint:(CGPoint)point direction:(HZPanDirection)direction{
    CGRect menuManagerViewFrame;
    CGRect panMenuViewFrame;
    CGPoint panMenuViewCenter;
    CGFloat scale = 0;
    CGPoint mapCenterPoint;
    if (direction == HZPanDirectionUp ) {
        if (point.y < 150.f) {
            menuManagerViewFrame = CGRectMake(0, 20.f, SCREEN_WIDTH, SCREEN_HEIGHT - 20.f);
            panMenuViewCenter = CGPointMake(SCREEN_WIDTH / 2, 90.f);
        } else {
            menuManagerViewFrame = CGRectMake(0, 150.f, SCREEN_WIDTH, SCREEN_HEIGHT - 150.f);
            panMenuViewCenter = CGPointMake(SCREEN_WIDTH / 2, 90.f);
        }
        mapCenterPoint = CGPointMake(SCREEN_WIDTH/2, 75.f);
        scale = 0.01f;
    } else {
        menuManagerViewFrame = CGRectMake(0, SCREEN_HEIGHT - 49.f, SCREEN_WIDTH, SCREEN_HEIGHT - 150.f);
        panMenuViewCenter = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 109.f);
        scale = 1.0;
        mapCenterPoint = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    }
    [UIView animateWithDuration:1.f animations:^{
        self.menuManagerView.frame = menuManagerViewFrame;
        self.panMenuView.center = panMenuViewCenter;
        self.panMenuView.transform = CGAffineTransformMakeScale(scale, scale);

    } completion:^(BOOL finished) {
        self.panMenuView.alpha = scale;
        self.statusView.alpha = 1-scale;
    }];
}

#pragma mark - Delegate HZMenuManagerViewDelegate
- (void)scrollWithY:(CGFloat) y panDirection:(HZPanDirection)panDirection animations:(BOOL) animations{
    NSLog(@"HZMenuManagerViewDelegate > y : %lf", y);
    CGFloat scale = y / (SCREEN_HEIGHT - 69.f);
    if (y < 150) {
        scale = 0.01f;
    }
    if (animations) {
        [UIView animateWithDuration:1.f animations:^{
            self.panMenuView.center = CGPointMake(SCREEN_WIDTH / 2, y - 60.f);
            self.panMenuView.transform = CGAffineTransformMakeScale(scale, scale);
        } completion:^(BOOL finished) {
            self.panMenuView.alpha = scale;
            self.statusView.alpha = 1-scale;
        }];
    } else {
        self.panMenuView.center = CGPointMake(SCREEN_WIDTH / 2, y - 60.f);
        self.panMenuView.transform = CGAffineTransformMakeScale(scale, scale);
        self.panMenuView.alpha = scale;
        self.statusView.alpha = 1-scale;
    }
    
    if (panDirection == HZPanDirectionUp || panDirection == HZPanDirectionDown) {
        CGPoint mapCenterPoint;
        if (panDirection == HZPanDirectionUp) {
            mapCenterPoint = CGPointMake(SCREEN_WIDTH/2, 75.f);

        } else if (panDirection == HZPanDirectionDown){
            mapCenterPoint = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        }
    }
}



@end
