//
//  HZMenuManagerView.m
//  Pods
//
//  Created by mason on 2018/5/16.
//
//

#import "HZMenuManagerView.h"
#import "HZMenuManagerItem.h"
#import "HZMenuManagerReusableView.h"
#import "ULBCollectionViewFlowLayout.h"
#import "HZBaseCollectionView.h"

@interface HZMenuManagerView()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
ULBCollectionViewDelegateFlowLayout,
HZBaseCollectionViewDelegate,
UIGestureRecognizerDelegate
>

@property (weak, nonatomic) IBOutlet HZBaseCollectionView *collectionView;

/** <##> */
@property (strong, nonatomic) NSArray *itemArray;
/** <##> */
@property (strong, nonatomic) UIPanGestureRecognizer *pan;

/** <##> */
@property (assign, nonatomic) CGFloat startMoveViewFrameY;
@end

@implementation HZMenuManagerView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
    [self addGestureRecognizer];
}

#pragma mark - setup UI
- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 11) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.baseCollectionViewdelegate = self;
    self.collectionView.contentInset = UIEdgeInsetsZero;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HZMenuManagerItem class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HZMenuManagerItem class])];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"meneCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HZMenuManagerReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([HZMenuManagerReusableView class])];
}

#pragma mark - Private Method
#pragma mark - 添加手势
- (void)addGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
    pan.delegate = self;
    [self.collectionView addGestureRecognizer:pan];
    self.pan = pan;
}

#pragma mark - 手势滑动
- (void)moveView:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"手势滑动 > recognizer.state : %ld", recognizer.state);
    if (CGRectGetMinY(self.frame) > 20) {
        CGPoint location = [recognizer translationInView:self.superview];
        CGFloat y = location.y + CGRectGetMinY(self.frame);
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.startMoveViewFrameY = CGRectGetMinY(self.frame);
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (y < 20) {
                y = 20;
            } else if (y > SCREEN_HEIGHT - 49.f) {
                y = SCREEN_HEIGHT - 49.f;
            }
            self.frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - 69.f);
            if ([self.delegate respondsToSelector:@selector(scrollWithY:panDirection:animations:)]) {
                [self.delegate scrollWithY:y panDirection:HZPanDirectionNone animations:NO];
            }
        } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            CGPoint locan = [recognizer translationInView:self.collectionView];
            HZPanDirection panDirection = HZPanDirectionNone;
            if (self.startMoveViewFrameY < CGRectGetMinY(self.frame)) {//向下
                y = SCREEN_HEIGHT - 49.f;
                panDirection = HZPanDirectionDown;
            } else {
                panDirection = HZPanDirectionUp;
                if (y < 150) {
                    y = 20;
                } else {
                    y = 150.f;
                }
            }
            [UIView animateWithDuration:1.f animations:^{
                self.frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - 69.f);
            } completion:^(BOOL finished) {
                
            }];
            if ([self.delegate respondsToSelector:@selector(scrollWithY:panDirection:animations:)]) {
                [self.delegate scrollWithY:y panDirection:panDirection animations:YES];
            }
        }
    } else if (CGRectGetMinY(self.frame) == 20) {
        CGPoint point = [recognizer translationInView:recognizer.view];//处理方向
        if (point.y > 0 && self.collectionView.contentOffset.y <= 0) {//向下
            [UIView animateWithDuration:1.f animations:^{
                self.frame = CGRectMake(0, SCREEN_HEIGHT - 49.f, SCREEN_WIDTH, SCREEN_HEIGHT - 69.f);
            } completion:^(BOOL finished) {
                
            }];
            if ([self.delegate respondsToSelector:@selector(scrollWithY:panDirection:animations:)]) {
                [self.delegate scrollWithY:SCREEN_HEIGHT - 49.f panDirection:HZPanDirectionDown animations:YES];
            }
        }
    }
    [recognizer setTranslation:CGPointZero inView:self.superview];
}

#pragma mark - Delegate UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Delegate HZBaseCollectionViewDelegate
- (CGFloat)fetchContainerViewWithStartY {
    return CGRectGetMinY(self.frame);
}

#pragma mark - Delegate UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.itemArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *items = self.itemArray[section][@"items"];
    return items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HZMenuManagerItem *menuManagerItem = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HZMenuManagerItem class]) forIndexPath:indexPath];
    NSArray *items = self.itemArray[indexPath.section][@"items"];
    menuManagerItem.contentDictionary = items[indexPath.row];
    return menuManagerItem;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = self.itemArray[indexPath.section][@"items"];
    NSDictionary *dic = items[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectedItemWithKey:)]) {
        [self.delegate didSelectedItemWithKey:dic[@"key"]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH / 4.f, 72.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 35.f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    HZMenuManagerReusableView *menuManagerReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([HZMenuManagerReusableView class]) forIndexPath:indexPath];
        NSDictionary *dic = self.itemArray[indexPath.section];
        menuManagerReusableView.title = dic[@"title"];
    
    return menuManagerReusableView;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15.f, 0.f, 25.f, 0.f);
}

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout colorForSectionAtIndex:(NSInteger)section {
    return [UIColor whiteColor];
}

#pragma mark - Property
- (NSArray *)itemArray {
    if (!_itemArray) {
        NSArray *riverManagerArray = @[
                                       @{@"title":@"我的河道", @"icon": @"home_wdhd"},
                                       @{@"title":@"河长名单", @"icon": @"home_xjhz"},
                                       @{@"title":@"污染防治", @"icon": @"home_wrfz"},
                                       @{@"title":@"排污监测", @"icon": @"home_pwjc"},
                                       @{@"title":@"水质查询", @"icon": @"home_szcx"},
                                       @{@"title":@"视频监控", @"icon": @"home_spjk"},
                                       @{@"title":@"视频直播", @"icon": @"home_live"},
                                       @{@"title":@"GIS监测", @"icon": @"home_gis"}

                                  ];
        NSArray *patrolRiverManagerArray = @[
                                             @{@"title":@"巡河记录", @"icon": @"home_xhjl"},
                                             @{@"title":@"开始巡河", @"icon": @"home_ksxh"}
                                   ];
        NSArray *eventManagerArray = @[
                                       @{@"title":@"事件查询", @"icon": @"home_sjcx"},
                                       @{@"title":@"投诉统计", @"icon": @"home_txtj"},
                                       @{@"title":@"待受理", @"icon": @"home_dsl"},
                                       @{@"title":@"待处理", @"icon": @"home_dcl"},
                                       @{@"title":@"待反馈", @"icon": @"home_dfk"},
                                       @{@"title":@"待结案", @"icon": @"home_dja"}
                                   ];
        NSArray *infoCenterArray = @[
                                       @{@"title":@"咨询中心", @"icon": @"home_information"}
                                       ];
        _itemArray = @[
                       @{@"title" : @"河道管理",
                         @"items" : riverManagerArray
                         },
                       @{@"title" : @"巡河管理",
                         @"items" : patrolRiverManagerArray
                         },
                       @{@"title" : @"事件管理",
                         @"items" : eventManagerArray
                         },
                       @{@"title" : @"事件管理",
                         @"items" : eventManagerArray
                         },
                       @{@"title" : @"咨询管理",
                         @"items" : infoCenterArray
                         }
                       ];
    }
    return _itemArray;
}

@end
















