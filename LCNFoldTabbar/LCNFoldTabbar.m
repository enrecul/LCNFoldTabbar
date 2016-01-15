//
//  LCNFoldTabbar.m
//  LCNFoldTabbar
//
//  Created by 黄春涛 on 16/1/14.
//  Copyright © 2016年 黄春涛. All rights reserved.
//

#import "LCNFoldTabbar.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static const CGFloat tabBarHeight = 49.0f;
static const CGFloat panViewWidth = 15.0f;
static const CGFloat animationDuration = 0.3;

@interface LCNFoldTabbar()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *panView;
@property (nonatomic, assign) CGFloat firstX;
@property (nonatomic, assign) CGFloat firstY;

@property (nonatomic, assign) BOOL isFold;

@end

@implementation LCNFoldTabbar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.isFold = YES;
        
        //setup Frame
        self.frame = CGRectMake(SCREEN_WIDTH - panViewWidth, SCREEN_HEIGHT - tabBarHeight, SCREEN_WIDTH, tabBarHeight);
        
        //setupSubView
        self.panView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, panViewWidth, tabBarHeight)];
        self.panView.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.panView];
        
        //setupGesture
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self.panView addGestureRecognizer:panRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        [self.panView addGestureRecognizer:tapRecognizer];
    }
    return self;
}


-(void)move:(id)sender {
    [self.superview bringSubviewToFront:[[(UIPanGestureRecognizer*)sender view] superview]];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.superview];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        self.firstX = [[sender view].superview center].x;
        self.firstY = [[sender view].superview center].y;
    }
    
    translatedPoint = CGPointMake(self.firstX + translatedPoint.x, SCREEN_HEIGHT - tabBarHeight/2);
    
    //运动范围限制
    if (translatedPoint.x < SCREEN_WIDTH/2) {
        translatedPoint.x = SCREEN_WIDTH/2;
    }
    if (translatedPoint.x > (SCREEN_WIDTH*3/2 - panViewWidth)) {
        translatedPoint.x = SCREEN_WIDTH*3/2 - panViewWidth;
    }

    self.center = translatedPoint;
    NSLog(@"%f,%f",translatedPoint.x,translatedPoint.y);
    
    //运动结束时判断位置，补全动画
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        CGPoint leftPoint = CGPointMake(translatedPoint.x - SCREEN_WIDTH/2, translatedPoint.y);
        if (leftPoint.x < SCREEN_WIDTH/2) {
            //展开Tabbar
            CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            moveAnimation.delegate = self;
            moveAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
            moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, translatedPoint.y)];
            moveAnimation.duration = (leftPoint.x/(SCREEN_WIDTH/2)) * animationDuration;
            moveAnimation.repeatCount = 1;
            moveAnimation.autoreverses = NO;
            moveAnimation.removedOnCompletion = NO;
            moveAnimation.fillMode = kCAFillModeForwards;
            moveAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.17 :.67 :.83 :.67];
            
            [self.layer addAnimation:moveAnimation forKey:@"Layer_Position"];
            self.center = CGPointMake(SCREEN_WIDTH/2, translatedPoint.y);
            
            self.isFold = NO;
        }
        else{
            //缩回Tabbar
            CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            moveAnimation.delegate = self;
            moveAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
            moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH*3/2 - panViewWidth, translatedPoint.y)];
            moveAnimation.duration = ((SCREEN_WIDTH - leftPoint.x)/(SCREEN_WIDTH/2)) * animationDuration;
            moveAnimation.repeatCount = 1;
            moveAnimation.autoreverses = NO;
            moveAnimation.removedOnCompletion = NO;
            moveAnimation.fillMode = kCAFillModeForwards;
            moveAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.17 :.67 :.83 :.67];
            
            [self.layer addAnimation:moveAnimation forKey:@"Layer_Position"];
            self.center = CGPointMake(SCREEN_WIDTH*3/2 - panViewWidth, translatedPoint.y);
            
            self.isFold = YES;
        }
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.layer removeAllAnimations];
}

- (void)tap{
    if (self.isFold) {
        //展开Tabbar
        CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        moveAnimation.delegate = self;
        moveAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
        moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - tabBarHeight/2)];
        moveAnimation.duration = animationDuration;
        moveAnimation.repeatCount = 1;
        moveAnimation.autoreverses = NO;
        moveAnimation.removedOnCompletion = NO;
        moveAnimation.fillMode = kCAFillModeForwards;
        //            http://cubic-bezier.com/#.17,.67,.83,.67
//        moveAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.17 :.67 :.83 :.67];
        
        [self.layer addAnimation:moveAnimation forKey:@"Layer_Position"];
        self.center = CGPointMake(SCREEN_WIDTH/2,SCREEN_HEIGHT - tabBarHeight/2);
        
        self.isFold = NO;
    }
    else{
        //缩回Tabbar
        CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        moveAnimation.delegate = self;
        moveAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
        moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH*3/2 - panViewWidth, SCREEN_HEIGHT - tabBarHeight/2)];
        moveAnimation.duration = animationDuration;
        moveAnimation.repeatCount = 1;
        moveAnimation.autoreverses = NO;
        moveAnimation.removedOnCompletion = NO;
        moveAnimation.fillMode = kCAFillModeForwards;
//        moveAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.17 :.67 :.83 :.67];
        
        [self.layer addAnimation:moveAnimation forKey:@"Layer_Position"];
        self.center = CGPointMake(SCREEN_WIDTH*3/2 - panViewWidth, SCREEN_HEIGHT - tabBarHeight/2);
        
        self.isFold = YES;
    }
}



@end
