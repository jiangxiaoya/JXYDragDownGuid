//
//  JXYGuideController.m
//  JXYDragDownGuide
//
//  Created by 蒋小丫 on 2018/11/28.
//  Copyright © 2018年 蒋小丫. All rights reserved.
//

#import "JXYGuideController.h"

#pragma mark -
#pragma mark - 模态转场动画开始 -
@interface JXYGuidePresentAnimate : NSObject<UIViewControllerAnimatedTransitioning>

@end

@implementation JXYGuidePresentAnimate

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
    JXYGuideController *toVC = (JXYGuideController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!toVC) {
        return;
    }
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [containerView addSubview:toVC.view];
    toVC.view.frame = containerView.bounds;
    toVC.view.alpha = 0;
    
    [UIView animateWithDuration:duration animations:^{
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .3;
}

@end

@interface JXYGuideDismissAnimate : NSObject<UIViewControllerAnimatedTransitioning>

@end

@implementation JXYGuideDismissAnimate

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (!fromVC) {
        return;
    }
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromVC.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.1;
}
@end


#pragma mark -
#pragma mark - 模态转场动画结束 -

//色值
#define kColorWithHex(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
//屏幕宽高
#define kScreenWidth \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.width)
#define kScreenHeight \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.height)

static CGFloat const kMoveDur = 1.0;
static CGFloat const kScaleDur = 0.06;
static CGFloat const distance = 156.0;
static CGFloat const lineWidth = 8.0;
static CGFloat const kBaseMargin = 4;

@interface JXYGuideController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *titleLbl;

@property (nonatomic, strong) CAShapeLayer *lineLayer;

@end

@implementation JXYGuideController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_init];
    [self p_addSwipDownGesture];
}

- (void)p_init {
    self.view.backgroundColor = [kColorWithHex(0x000000) colorWithAlphaComponent:0.5];
    [self.view.layer addSublayer:self.lineLayer];
    [self.view addSubview:self.imgV];
    [self.view addSubview:self.titleLbl];
}

- (void)p_addAnim {
    CAAnimationGroup *handAnim = [self p_animHand];
    [self.imgV.layer addAnimation:handAnim forKey:@"handAnimGroup"];
    
    CAAnimationGroup *lineAnim = [self p_animLine];
    [self.lineLayer addAnimation:lineAnim forKey:@"lineAnimGroup"];
}

- (void)p_addSwipDownGesture {
    
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipDownAct:)];
    [swip setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swip];
}

- (void)swipDownAct:(UISwipeGestureRecognizer *)swip {
    [self.imgV.layer removeAllAnimations];
    [self.lineLayer removeAllAnimations];
    [self dismissViewControllerAnimated:NO completion:^{
        !self.closeDone ? : self.closeDone();
    }];

}


#pragma mark -
#pragma mark - animation -

- (CAAnimationGroup *)p_animHand {
    
    //位移
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    move.duration = kMoveDur;
    move.removedOnCompletion = NO;
    move.fillMode = kCAFillModeForwards;
    move.toValue = [NSValue valueWithCGPoint:CGPointMake(kScreenWidth/2.0-lineWidth/2.0, self.imgV.frame.origin.y+distance)];
    
    //缩放
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    scale.fromValue = @(1);
    scale.toValue = @(0.01);
    scale.beginTime = move.duration;
    scale.duration = kScaleDur;
    
    //透明度
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.toValue = @(0);
    opacity.removedOnCompletion = YES;
    opacity.fillMode = kCAFillModeRemoved;
    opacity.beginTime = scale.beginTime+scale.duration;
    opacity.duration = kScaleDur;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[move,scale,opacity];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.duration = move.duration+scale.duration+scale.duration;
    group.repeatCount = MAXFLOAT;
    
    return group;
}

- (CAAnimationGroup *)p_animLine {
    
    //淡入
    CABasicAnimation *show = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    show.duration = kMoveDur;
    show.fromValue = @(0);
    show.toValue = @(1);
    show.removedOnCompletion= YES;
    show.fillMode = kCAFillModeRemoved;
    
    //淡出
    CABasicAnimation *dismiss = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    dismiss.beginTime = show.duration+kScaleDur;
    dismiss.duration = kScaleDur;
    dismiss.removedOnCompletion = NO;
    dismiss.fillMode = kCAFillModeForwards;
    dismiss.fromValue = @(1);
    dismiss.toValue = @(0);
    
    //透明度
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.toValue = @(0);
    opacity.removedOnCompletion = YES;
    opacity.fillMode = kCAFillModeRemoved;
    opacity.beginTime = dismiss.beginTime;
    opacity.duration = kScaleDur;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[show,dismiss,opacity];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.duration = kMoveDur+kScaleDur*2;
    group.repeatCount = MAXFLOAT;
    
    return group;
}

- (void)viewDidLayoutSubviews {
    
    CGFloat height = 46;
    CGFloat width = kScreenWidth;
    CGFloat originY = (kScreenHeight - height)/2.0;
    CGFloat originX = 0;
    self.titleLbl.frame = CGRectMake(originX, originY, width, height);
    
    originX = kScreenWidth/2.0-lineWidth/2.0;
    originY = 19*kBaseMargin;
    width = 56;
    height = 56;
    self.imgV.frame = CGRectMake(originX, originY, width, height);
    
    [self p_addAnim];
}


#pragma mark -
#pragma mark - lazy -

- (UIImageView *)imgV{
    
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
        _imgV.layer.anchorPoint = CGPointMake(0.0, 0.0);
        _imgV.image = [UIImage imageNamed:@"img_guidance_hand"];
    }
    return _imgV;
}

- (UILabel *)titleLbl{
    
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.numberOfLines = 0;
        _titleLbl.textColor = kColorWithHex(0xffffff);
        _titleLbl.font = [UIFont systemFontOfSize:16];
        _titleLbl.text = @"下拉加载更多";
        _titleLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLbl;
}
- (CAShapeLayer *)lineLayer{
    
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(kScreenWidth/2.0, 19*kBaseMargin)];
        [path addLineToPoint:CGPointMake(kScreenWidth/2.0, 19*kBaseMargin+distance)];
        _lineLayer.path = path.CGPath;
        _lineLayer.lineWidth = lineWidth;
        _lineLayer.lineCap = kCALineCapRound;
        _lineLayer.lineJoin = kCALineJoinRound;
        _lineLayer.strokeColor = kColorWithHex(0xFFCE25).CGColor;
    }
    return _lineLayer;
}


#pragma mark -
#pragma mark -- UIViewControllerTransitioningDelegate --

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[JXYGuidePresentAnimate alloc] init];
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[JXYGuideDismissAnimate alloc] init];
}



@end
