# UIVeiw与UIScrollView嵌套，手势/滚动冲突的解决
## 前言
#### 在项目开发过程中，遇到一个这样的需求：
+ 在视图向上拖动时，使得视图暂时不到顶，而是停留在某个高度处，
+ 此时如果向上拖动，则可以到达顶部
+ 达到顶部后，视图中的子视图才可以滚动（内容足够多）
+ 在向下拖动时，子视图全部展示在顶部时，才允许外部视图向下滚动  

#### 具体过程如图：
<image src = "http://7qnbrb.com1.z0.glb.clouddn.com/scrollviewNest.gif"  width=320>

## 问题
实现这一功能，只能通过UIScrollView的嵌套或者UIView中添加UIScrollView方式（我能想到的，有更好的做法，可以留言指出）

但不管采用哪种方案，有一个重要的问题需要处理：**事件冲突**

在一般的情况下，只有UIScrollView及其子类才具备滚动的功能，不管是**UIScrollView的嵌套**还是在普通的**UIView中添加UIScrollView**，都会出现冲突

## 方案
采用UIView中添加UICollectionView,然后给UICollectionView添加手势，通过位置，拦截事件响应的对象。

## 实现
这里需要用到两个重要的概念（非常关键）
~~~
1.这个是UIView关于手势事件的拓展方法，返回值为NO时，表示不触发手势事件，该方法在此处运用时，即禁掉自定义添加的拖动手势，响应UICollecionView的滚动手势，我们可以在这个方法中获取到view的当前位置，以及手势的方向，根据这两个因素，就可以决定是否响应事件了
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        if ([self.delegate respondsToSelector:@selector(fetchContainerViewWithStartY)]) {
            /*通过代理获取view的当前位置*/
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

2.是否支持都是否事件共存，解决问题的关键，这里需要返回YES，我们对UICollectionView添加了自定义的拖动手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
~~~

在自定义的手势事件中，根据手势的状态，滚动方向以及位置来处理视图的frame，在项目中还配合了一个拖动的小按钮，所以在方法中，还有一个回调的事件
~~~

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
                //回调处理，拖动的小图标
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
                //回调处理，拖动的小图标
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
                //回调处理，拖动的小图标
                [self.delegate scrollWithY:SCREEN_HEIGHT - 49.f panDirection:HZPanDirectionDown animations:YES];
            }
        }
    }
    [recognizer setTranslation:CGPointZero inView:self.superview];
}

~~~

[传送门](https://github.com/hmx101607/ScrollViewNest)

 



