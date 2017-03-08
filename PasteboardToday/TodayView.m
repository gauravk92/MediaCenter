//
//  TodayView.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/11/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "TodayView.h"

#define PROMO_ICON_VIEW 0

static inline CGFLOAT_TYPE cground(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

@interface TodayView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIBezierPath *pasteButtonPath;
@property (nonatomic, strong) UIView *borderPath;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *onImage;
@property (nonatomic, strong) UILabel *offImage;
@property (nonatomic, strong) UIImageView *powerImage;
@property (nonatomic, strong) UIImageView *volumeUpImage;
@property (nonatomic, strong) UIImageView *volumeDownImage;

@property (nonatomic, strong) UILongPressGestureRecognizer *powerOnGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *powerOffGestureRecognizer;

@property (nonatomic, strong) UIButton *input1Button;
@property (nonatomic, strong) UIButton *input2Button;
@property (nonatomic, strong) UIButton *input3Button;

@property (nonatomic, strong) UILongPressGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic, strong) UILongPressGestureRecognizer *volumeDownTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *volumeDownHoldGestureRecognizer;

@property (nonatomic, strong) UILongPressGestureRecognizer *volumeUpTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *volumeUpHoldGestureRecognizer;

@property (nonatomic, strong) NSMethodSignature *actionSignature;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval animationDelay;
@property (nonatomic, strong) NSOperationQueue *animationsQueue;
@property (nonatomic, assign) BOOL showingPowerAndVolume;

@property (nonatomic, strong) NSOperationQueue *holdGestureQueue;
@property (nonatomic, strong) NSTimer *holdGestureTimer;
@property (nonatomic, assign) NSTimeInterval holdGestureInterval;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TodayView

- (instancetype)initWithEffect:(UIVisualEffect *)effect {
    self = [super initWithEffect:effect];
    if (self) {
        UIView *contentView = self.contentView;
        
#if PROMO_ICON_VIEW
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_pic"]];
        [self.contentView addSubview:_imageView];
        
#else
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _textLabel.text = @"Living Room";
        _textLabel.layer.shouldRasterize = YES;
        _textLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _textLabel.font = [UIFont systemFontOfSize:20.0];
        //_textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:_textLabel];
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        _stateLabel.text = @"CONNECTING";
        _stateLabel.layer.shouldRasterize = YES;
        _stateLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _stateLabel.font = [UIFont systemFontOfSize:12.0];
        [_stateLabel sizeToFit];
        [contentView addSubview:_stateLabel];
        
        _onImage = [[UILabel alloc] initWithFrame:CGRectZero];
        _onImage.text = @"ON";
        _onImage.font = [UIFont systemFontOfSize:14.0];
        _onImage.textColor = [UIColor whiteColor];
        [_onImage sizeToFit];
        _onImage.layer.shouldRasterize = YES;
        _onImage.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [contentView addSubview:_onImage];
        
        _offImage = [[UILabel alloc] initWithFrame:CGRectZero];
        _offImage.text = @"OFF";
        _offImage.font = [UIFont systemFontOfSize:14.0];
        _offImage.textColor = [UIColor whiteColor];
        [_offImage sizeToFit];
        _offImage.layer.shouldRasterize = YES;
        _offImage.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [contentView addSubview:_offImage];
        
        _powerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"power1_full"]];
        [contentView addSubview:_powerImage];
        
        _volumeUpImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"volume1_full"]];
        [contentView addSubview:_volumeUpImage];
        
        _volumeDownImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"volume2_full"]];
        [contentView addSubview:_volumeDownImage];
        
        _powerOnGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(powerOnGesture:)];
        _powerOnGestureRecognizer.minimumPressDuration = 0.01;
        _powerOnGestureRecognizer.numberOfTapsRequired = 0;
        _powerOnGestureRecognizer.delegate = self;
        [contentView addGestureRecognizer:_powerOnGestureRecognizer];
        
        _powerOffGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(powerOffGesture:)];
        _powerOffGestureRecognizer.minimumPressDuration = 0.01;
        _powerOffGestureRecognizer.numberOfTapsRequired = 0;
        _powerOffGestureRecognizer.delegate = self;
        [contentView addGestureRecognizer:_powerOffGestureRecognizer];
        
        _tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _tapGestureRecognizer.minimumPressDuration = 0.01;
        _tapGestureRecognizer.numberOfTapsRequired = 0;
        _tapGestureRecognizer.delegate = self;
        [contentView addGestureRecognizer:_tapGestureRecognizer];
        
        _doubleTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
        _doubleTapGestureRecognizer.minimumPressDuration = 0.01;
        _doubleTapGestureRecognizer.numberOfTapsRequired = 1;
        _doubleTapGestureRecognizer.delegate = self;
        [contentView addGestureRecognizer:_doubleTapGestureRecognizer];
        
        [_tapGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];
        
        
        _volumeDownTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(volumeDownTapGesture:)];
        _volumeDownTapGestureRecognizer.minimumPressDuration = 0.01;
        _volumeDownTapGestureRecognizer.numberOfTapsRequired = 0;
        [_volumeDownImage addGestureRecognizer:_volumeDownTapGestureRecognizer];
        
        _volumeDownHoldGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(volumeDownHoldGesture:)];
        _volumeDownHoldGestureRecognizer.minimumPressDuration = 0.01;
        _volumeDownHoldGestureRecognizer.numberOfTapsRequired = 0;
        [_volumeDownImage addGestureRecognizer:_volumeDownHoldGestureRecognizer];
        
        _volumeUpTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(volumeUpTapGesture:)];
        _volumeUpTapGestureRecognizer.minimumPressDuration = 0.01;
        _volumeUpTapGestureRecognizer.numberOfTapsRequired = 0;
        [_volumeUpImage addGestureRecognizer:_volumeUpTapGestureRecognizer];
        
        _volumeUpHoldGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(volumeUpHoldGesture:)];
        _volumeUpHoldGestureRecognizer.minimumPressDuration = 0.01;
        _volumeUpHoldGestureRecognizer.numberOfTapsRequired = 0;
        [_volumeUpImage addGestureRecognizer:_volumeUpHoldGestureRecognizer];
        
        
        [_volumeDownTapGestureRecognizer requireGestureRecognizerToFail:_volumeDownHoldGestureRecognizer];
        [_volumeUpTapGestureRecognizer requireGestureRecognizerToFail:_volumeUpHoldGestureRecognizer];
        
        _showingPowerAndVolume = YES;
        
        _animationDuration = -1;
        _animationDelay = -1;
        _animationsQueue = [NSOperationQueue new];
        _animationsQueue.maxConcurrentOperationCount = 1;
        _actionSignature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        
        _holdGestureInterval = 0.2;
        _holdGestureQueue = [NSOperationQueue new];
        _holdGestureQueue.maxConcurrentOperationCount = 1;
        
#endif
        
    }
    return self;
}

- (void)setupInputButtons {
    if (!self.input1Button.superview) {
        
        self.input1Button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.input1Button setImage:[UIImage imageNamed:@"hdmi1"] forState:UIControlStateNormal];
        [self.input1Button addTarget:self action:@selector(input1ButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.input2Button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.input2Button setImage:[UIImage imageNamed:@"hdmi2"] forState:UIControlStateNormal];
        [self.input2Button addTarget:self action:@selector(input2ButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.input3Button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.input3Button setImage:[UIImage imageNamed:@"hdmi3"] forState:UIControlStateNormal];
        [self.input3Button addTarget:self action:@selector(input3ButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.input1Button];
        [self.contentView addSubview:self.input2Button];
        [self.contentView addSubview:self.input3Button];
        
        CGFloat lMargin = 12.0;
        CGFloat margin = 9;
        CGFloat size = 52.0;
        
        CGFloat frameWidth = CGRectGetWidth(self.frame);
        CGFloat centerPoint = (CGRectGetHeight(self.frame) / 2) - (size / 2);
        
        self.input3Button.frame = CGRectIntegral(CGRectMake(frameWidth - lMargin - size, centerPoint, size, size));
        self.input2Button.frame = CGRectIntegral(CGRectMake(frameWidth - lMargin - size - margin - size, centerPoint, size, size));
        self.input1Button.frame = CGRectIntegral(CGRectMake(frameWidth - lMargin - size - margin - size - margin - size, centerPoint, size, size));
        
    }
}

const CGFloat centerButtonWidth = 60;

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.tapGestureRecognizer || gestureRecognizer == self.doubleTapGestureRecognizer) {
        CGPoint point = [touch locationInView:self.contentView];
        if (point.x < self.frame.size.width /2 - 50) {
            return YES;
        }
    }
    if (gestureRecognizer == self.powerOnGestureRecognizer) {
        CGPoint point = [touch locationInView:self.contentView];
        CGPoint center = self.center;
        if (point.x > center.x - centerButtonWidth/2 && point.x < center.x + centerButtonWidth/2 && point.y < center.y) {
            return YES;
        }
    }
    if (gestureRecognizer == self.powerOffGestureRecognizer) {
        CGPoint point = [touch locationInView:self.contentView];
        CGPoint center = self.center;
        if (point.x > center.x - centerButtonWidth/2 && point.x < center.x + centerButtonWidth/2 && point.y > center.y) {
            return YES;
        }
    }
    return NO;
}

- (void)volumeUpTapGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.volumeUpImage.alpha = 0.3;
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        self.volumeUpImage.alpha = 1;
        [self volumeUpAction:nil];
    }
    if (gc.state == UIGestureRecognizerStateCancelled || gc.state == UIGestureRecognizerStateFailed) {
        self.volumeUpImage.alpha = 1;
    }
}

- (void)volumeDownTapGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.volumeDownImage.alpha = 0.3;
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        [self volumeDownAction:nil];
        self.volumeDownImage.alpha = 1;
    }
    if (gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
        self.volumeDownImage.alpha = 1;
    }
}

- (void)volumeUpThrottle:(NSTimer*)timer {
//    __weak TodayView *weakSelf = self;
//    
//    NSBlockOperation *blockOperation = [NSBlockOperation new];
//    __weak NSBlockOperation *weakBlock = blockOperation;
//    
//    [blockOperation addExecutionBlock:^{
//        
//        if (weakBlock.isCancelled) {
//            return;
//        }
//        
//        TodayView *strongSelf = weakSelf;
//        [strongSelf.holdGestureQueue cancelAllOperations];
//        strongSelf.holdGestureQueue = nil;
//        
        [self volumeUpAction:nil];
//        
//        strongSelf.holdGestureQueue = [NSOperationQueue new];
//        strongSelf.holdGestureQueue.maxConcurrentOperationCount = 1;
//        
//    }];
//    [self.holdGestureQueue addOperation:blockOperation];
}

- (void)volumeDownThrottle:(NSTimer*)timer {
//    __weak TodayView *weakSelf = self;
//    
//    NSBlockOperation *blockOperation = [NSBlockOperation new];
//    __weak NSBlockOperation *weakBlock = blockOperation;
//    
//    [blockOperation addExecutionBlock:^{
//    
//        if (weakBlock.isCancelled) {
//            return;
//        }
//        
//        TodayView *strongSelf = weakSelf;
//        [strongSelf.holdGestureQueue cancelAllOperations];
//        strongSelf.holdGestureQueue = nil;
//        
        [self volumeDownAction:nil];
//        
//        strongSelf.holdGestureQueue = [NSOperationQueue new];
//        strongSelf.holdGestureQueue.maxConcurrentOperationCount = 1;
//        
//    }];
//    [self.holdGestureQueue addOperation:blockOperation];
}

- (void)volumeUpHoldGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        // start action and timer
        __weak TodayView *weakSelf = self;
        
        NSBlockOperation *blockOperation = [NSBlockOperation new];
        __weak NSBlockOperation *weakBlock = blockOperation;
        
        self.volumeUpImage.alpha = 0.3;
        
        [blockOperation addExecutionBlock:^{
            
            if (weakBlock.isCancelled) {
                return;
            }
            
            TodayView *strongSelf = weakSelf;
            
            [strongSelf volumeUpAction:nil];
            
            [strongSelf.holdGestureQueue cancelAllOperations];
            strongSelf.holdGestureQueue = nil;
            
            strongSelf.holdGestureTimer = [NSTimer timerWithTimeInterval:strongSelf.holdGestureInterval
                                                                  target:strongSelf
                                                                selector:@selector(volumeUpThrottle:)
                                                                userInfo:nil
                                                                 repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:strongSelf.holdGestureTimer forMode:NSRunLoopCommonModes];
            
        }];
        [self.holdGestureQueue addOperation:blockOperation];
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized
        || gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
        // cancel timer and queue
        [self.holdGestureTimer invalidate];
        self.holdGestureTimer = nil;
        [self.holdGestureQueue cancelAllOperations];
        self.holdGestureQueue = [NSOperationQueue new];
        self.holdGestureQueue.maxConcurrentOperationCount = 1;
        self.volumeUpImage.alpha = 1;
    }
}

- (void)volumeDownHoldGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        // start action and timer
        __weak TodayView *weakSelf = self;
        
        NSBlockOperation *blockOperation = [NSBlockOperation new];
        __weak NSBlockOperation *weakBlock = blockOperation;
        
        self.volumeDownImage.alpha = 0.3;
        
        [blockOperation addExecutionBlock:^{
            
            if (weakBlock.isCancelled) {
                return;
            }
            
            TodayView *strongSelf = weakSelf;
            
            [strongSelf volumeDownAction:nil];
            
            [strongSelf.holdGestureQueue cancelAllOperations];
            strongSelf.holdGestureQueue = nil;
            
            strongSelf.holdGestureTimer = [NSTimer timerWithTimeInterval:strongSelf.holdGestureInterval
                                                                  target:strongSelf
                                                                selector:@selector(volumeDownThrottle:)
                                                                userInfo:nil
                                                                 repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:strongSelf.holdGestureTimer forMode:NSRunLoopCommonModes];
            
        }];
        [self.holdGestureQueue addOperation:blockOperation];
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized
        || gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
        // cancel timer and queue
        [self.holdGestureTimer invalidate];
        self.holdGestureTimer = nil;
        [self.holdGestureQueue cancelAllOperations];
        self.holdGestureQueue = [NSOperationQueue new];
        self.holdGestureQueue.maxConcurrentOperationCount = 1;
        self.volumeDownImage.alpha = 1;
    }
}

- (void)powerOnGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.onImage.alpha = 0.3;
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        [self powerOnAction];
        self.onImage.alpha = 1;
    }
    if (gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
        self.onImage.alpha = 1;
    }
}

- (void)powerOffGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        self.offImage.alpha = 0.3;
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        [self powerOffAction];
        self.offImage.alpha = 1;
    }
    if (gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
        self.offImage.alpha = 1;
    }
}

- (void)tapGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        [self showDoubleTapToMute];
        [self animateButtonInOutAction];
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        
    }
    if (gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
        
    }
}

- (void)doubleTapGesture:(UILongPressGestureRecognizer*)gc {
    if (gc.state == UIGestureRecognizerStateBegan) {
        
    }
    if (gc.state == UIGestureRecognizerStateEnded || gc.state == UIGestureRecognizerStateRecognized) {
        [self showMuted];
        [self volumeMuteAction:nil];
    }
    if (gc.state == UIGestureRecognizerStateFailed || gc.state == UIGestureRecognizerStateCancelled) {
        
    }
}


//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        //[[self class] addEdgeConstraint:NSLayoutAttributeLeft superview:contentView subview:customView];
//        //[[self class] addEdgeConstraint:NSLayoutAttributeRight superview:contentView subview:customView];
//        //[[self class] addEdgeConstraint:NSLayoutAttributeTop superview:contentView subview:customView];
//        //[[self class] addEdgeConstraint:NSLayoutAttributeBottom superview:contentView subview:customView];
//        self.translatesAutoresizingMaskIntoConstraints = NO;
//        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        self.contentMode = UIViewContentModeRedraw;
//        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        //self.layer.shouldRasterize = YES;
//        //self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        
////        self.borderPath = [[UIView alloc] initWithFrame:CGRectZero];
////        self.borderPath.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
////        self.borderPath.layer.shouldRasterize = YES;
////        self.borderPath.layer.rasterizationScale = [UIScreen mainScreen].scale;
////        [self addSubview:self.borderPath];
//    }
//    return self;
//}


- (void)layoutSubviews {
    [super layoutSubviews];
    
#if PROMO_ICON_VIEW
    
    self.imageView.center = self.center;
    
#endif

    self.textLabel.center = CGPointMake(0, self.center.y);
    CGRect frame = self.textLabel.frame;
    frame.origin.x = 12.0;
    self.textLabel.frame = frame;
    
    CGFloat centerY = self.center.y;
    
    CGFloat margin = 12.0;
    CGFloat frameWidth = CGRectGetWidth(self.frame);
    CGFloat frameHeight = CGRectGetHeight(self.frame);
    CGFloat volumeUpWidth = CGRectGetWidth(self.volumeUpImage.frame);
    CGFloat volumeDownWidth = CGRectGetWidth(self.volumeDownImage.frame);
    
    CGFloat onOffCenterMargin = 28;
    self.onImage.center = CGPointMake(self.center.x, self.center.y - onOffCenterMargin);
    self.offImage.center = CGPointMake(self.center.x, self.center.y + onOffCenterMargin);
    self.powerImage.center = self.center;
    //self.powerButton.center = CGPointMake(frameWidth - margin - volumeDownWidth - margin - volumeUpWidth - margin - (powerWidth/2), self.center.y);
    self.volumeDownImage.center = CGPointMake(frameWidth - margin - volumeDownWidth - margin - (volumeUpWidth/2), centerY);
    self.volumeUpImage.center = CGPointMake(frameWidth - margin - (volumeDownWidth/2), centerY);
    
    self.onImage.frame = CGRectIntegral(self.onImage.frame);
    self.offImage.frame = CGRectIntegral(self.offImage.frame);
    self.powerImage.frame = CGRectIntegral(self.powerImage.frame);
    self.volumeUpImage.frame = CGRectIntegral(self.volumeUpImage.frame);
    self.volumeDownImage.frame = CGRectIntegral(self.volumeDownImage.frame);
    

    CGFloat spacing = 1;
    CGFloat leftMargin = 8;
    CGFloat centerPoint = (frameHeight/2);
    CGSize stateLabelSize = self.stateLabel.frame.size;
    self.stateLabel.frame = CGRectIntegral(CGRectMake(leftMargin, centerPoint + spacing, stateLabelSize.width, stateLabelSize.height));

    CGFloat textMaxWidth = self.powerImage.frame.origin.x - margin;
    CGSize textSize = [self.textLabel sizeThatFits:CGSizeMake(textMaxWidth, frameHeight)];
    self.textLabel.frame = CGRectIntegral(CGRectMake(leftMargin, self.stateLabel.frame.origin.y - textSize.height, textMaxWidth, textSize.height));
    
}

- (void)setStatusDisplay {
    self.stateLabel.text = @"POWER OFF";
}

- (void)setPowerOnDisplay {
    self.stateLabel.text = @"POWER ON";
}

- (void)setConnectedDisplay {
    self.stateLabel.text = @"CONNECTED";
}

- (void)setErrorDisplay {
    self.stateLabel.text = @"ERROR";
}

- (void)setPoweredOffDisplay {
    self.stateLabel.text = @"POWERED OFF";
}

- (void)setPoweredOnDisplay {
    self.stateLabel.text = @"POWERED ON";
}

- (void)setRetryingDisplay {
    self.stateLabel.text = @"RETRYING";
}

- (void)setDoubleTapToMuteDisplay {
    self.stateLabel.text = @"DBL TAP TO MUTE";
}

- (void)setSwitchInputDisplay {
    self.stateLabel.text = @"SELECT INPUT";
}

- (void)setMutedDisplay {
    self.stateLabel.text = @"MUTED";
}

- (void)setConnectingDisplay {
    self.stateLabel.text = @"CONNECTING";
}

- (void)setUnreachableDisplay {
    self.stateLabel.text = @"UNREACHABLE";
}

- (void)setPoweringDisplay {
    self.stateLabel.text = @"POWERING ON";
}

#pragma mark -
#pragma mark - State Transition Methods

- (void)showPoweredOff {
    [self animateStateInOutAction:@selector(setPoweredOffDisplay) secondAction:@selector(setConnectedDisplay)];
}

- (void)showDoubleTapToMute {
    [self beginAnimationInOut];
    [self setAnimationInOutDelay:0.8];
    [self animateStateInOutAction:@selector(setDoubleTapToMuteDisplay) secondAction:@selector(setSwitchInputDisplay)];
    [self commitAnimationInOut];
}

- (void)showConnected {
    [self animateStateInOutAction:@selector(setConnectedDisplay) secondAction:@selector(setStatusDisplay)];
}

- (void)showError {
    [self animateStateInOutAction:@selector(setErrorDisplay)];
}

- (void)showRetrying {
    [self animateStateInOutAction:@selector(setErrorDisplay)];
}

- (void)showMuted {
    [self animateStateInOutAction:@selector(setMutedDisplay) secondAction:@selector(setStatusDisplay)];
}

- (void)showPoweringOn {
    [self animateStateInOutAction:@selector(setPoweringDisplay) secondAction:@selector(setPowerOnDisplay)];
}

- (void)showConnecting {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.0];
    [self setConnectingDisplay];
    [self.stateLabel sizeToFit];
    self.stateLabel.alpha = 1;
    [CATransaction commit];
}

- (void)showUnreachable {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.0];
    [self setUnreachableDisplay];
    [self.stateLabel sizeToFit];
    self.stateLabel.alpha = 1;
    [CATransaction commit];
}

#pragma mark - 
#pragma mark - Animation Transaction Methods

- (void)beginAnimationInOut {
    self.animationDuration = -1;
    self.animationDelay = -1;
}

- (void)setAnimationInOutDuration:(NSTimeInterval)duration {
    self.animationDuration = duration;
}

- (void)setAnimationInOutDelay:(NSTimeInterval)delay {
    self.animationDelay = delay;
}

- (void)commitAnimationInOut {
    self.animationDuration = -1;
    self.animationDelay = -1;
}

- (void)cancelAllInOutAnimations {
    [self.animationsQueue cancelAllOperations];
    [self.stateLabel.layer removeAllAnimations];
    self.animationsQueue = [[NSOperationQueue alloc] init];
    self.animationsQueue.maxConcurrentOperationCount = 1;
}

#pragma mark -
#pragma mark - View State Methods

const CGFloat animationDuration = 0.7;
const CGFloat animationDelay = 0.2;
const UIViewAnimationOptions opts = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState;

- (void)animateStateInOutAction:(SEL)actionSelector  {
    __weak TodayView *weakSelf = self;
    NSTimeInterval animationInDuration = (self.animationDuration > -1) ? self.animationDuration : animationDuration;
    NSTimeInterval animationInDelay = (self.animationDelay > -1) ? self.animationDelay : animationDelay;
    
    NSInvocation *action = [NSInvocation invocationWithMethodSignature:self.actionSignature];
    action.target = self;
    [action setSelector:actionSelector];
    
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    __weak NSBlockOperation *weakBlock = blockOperation;
    [blockOperation addExecutionBlock:^{
    
        if (weakBlock.isCancelled) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [UIView animateWithDuration:animationInDuration delay:0 options:opts animations:^{
                weakSelf.stateLabel.alpha = 0;
            } completion:^(BOOL finished) {
                if (finished && !weakBlock.isCancelled) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [action invoke];
                        [weakSelf.stateLabel sizeToFit];
                        [UIView animateWithDuration:animationInDuration delay:animationInDelay options:UIViewAnimationOptionCurveLinear animations:^{
                            weakSelf.stateLabel.alpha = 1;
                        } completion:nil];
                    });
                }
            }];
            
        });
    }];
    [self.animationsQueue addOperation:blockOperation];
}

- (void)animateStateInOutAction:(SEL)actionSelector secondAction:(SEL)secondActionSelector {
    __weak TodayView *weakSelf = self;
    NSTimeInterval animationInDuration = (self.animationDuration > -1) ? self.animationDuration : animationDuration;
    NSTimeInterval animationInDelay = (self.animationDelay > -1) ? self.animationDelay : animationDelay;
    
    NSInvocation *action = [NSInvocation invocationWithMethodSignature:self.actionSignature];
    action.target = self;
    [action setSelector:actionSelector];
    
    NSInvocation *secondAction = [NSInvocation invocationWithMethodSignature:self.actionSignature];
    secondAction.target = self;
    [secondAction setSelector:secondActionSelector];
    
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    __weak NSBlockOperation *weakBlock = blockOperation;
    [blockOperation addExecutionBlock:^{
    
        if (weakBlock.isCancelled) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [UIView animateWithDuration:animationInDuration delay:0 options:opts animations:^{
                weakSelf.stateLabel.alpha = 0;
            } completion:^(BOOL finished) {
                if (finished && !weakBlock.isCancelled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [action invoke];
                        [weakSelf.stateLabel sizeToFit];
                        
                        [UIView animateWithDuration:animationInDuration delay:animationDelay options:opts animations:^{
                            weakSelf.stateLabel.alpha = 1;
                        } completion:^(BOOL finished) {
                            if (finished && !weakBlock.isCancelled) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [UIView animateWithDuration:animationDuration delay:animationInDelay options:opts animations:^{
                                        weakSelf.stateLabel.alpha = 0;
                                    } completion:^(BOOL finished) {
                                        if (finished && !weakBlock.isCancelled) {
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [secondAction invoke];
                                                [weakSelf.stateLabel sizeToFit];
                                                [UIView animateWithDuration:animationDuration delay:animationDelay options:opts animations:^{
                                                    weakSelf.stateLabel.alpha = 1;
                                                } completion:nil];
                                            });
                                        }
                                    }];
                                });
                            }
                        }];
                    });
                    
                }
            }];
        
        });
    }];
    [self.animationsQueue addOperation:blockOperation];
}


- (void)animateButtonInOutAction {
    
    __weak TodayView *weakSelf = self;
    
    NSBlockOperation *blockOperation = [NSBlockOperation new];
    __weak NSBlockOperation *weakBlock = blockOperation;
    
    BOOL showingPowerAndVolume = self.showingPowerAndVolume;
    
    [blockOperation addExecutionBlock:^{
    
        if (weakBlock.isCancelled) {
            return;
        }
        
        [weakSelf.animationsQueue cancelAllOperations];
        weakSelf.animationsQueue = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            TodayView *strongSelf = weakSelf;
            
            if (showingPowerAndVolume) {
                [strongSelf setupInputButtons];
            } else {
                [strongSelf.contentView addSubview:strongSelf.onImage];
                [strongSelf.contentView addSubview:strongSelf.offImage];
                [strongSelf.contentView addSubview:strongSelf.powerImage];
                [strongSelf.contentView addSubview:strongSelf.volumeDownImage];
                [strongSelf.contentView addSubview:strongSelf.volumeUpImage];
            }
            
            [UIView animateWithDuration:0.3 delay:0.0 options:opts animations:^{
                TodayView *strongSelf = weakSelf;
                if (showingPowerAndVolume) {
                    strongSelf.onImage.alpha = 0;
                    strongSelf.offImage.alpha = 0;
                    strongSelf.powerImage.alpha = 0;
                    strongSelf.volumeDownImage.alpha = 0;
                    strongSelf.volumeUpImage.alpha = 0;
                } else {
                    strongSelf.input1Button.alpha = 0;
                    strongSelf.input2Button.alpha = 0;
                    strongSelf.input3Button.alpha = 0;
                }
            } completion:^(BOOL finished) {
                if (finished && !weakBlock.isCancelled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        TodayView *strongSelf = weakSelf;
                        if (showingPowerAndVolume) {
                            [strongSelf.onImage removeFromSuperview];
                            [strongSelf.offImage removeFromSuperview];
                            [strongSelf.powerImage removeFromSuperview];
                            [strongSelf.volumeUpImage removeFromSuperview];
                            [strongSelf.volumeDownImage removeFromSuperview];
                        } else {
                            [strongSelf.input1Button removeFromSuperview];
                            [strongSelf.input2Button removeFromSuperview];
                            [strongSelf.input3Button removeFromSuperview];
                        }
                        
                        [UIView animateWithDuration:0.3 delay:0.1 options:opts animations:^{
                            TodayView *strongSelf = weakSelf;
                            if (showingPowerAndVolume) {
                                strongSelf.input1Button.alpha = 1;
                                strongSelf.input2Button.alpha = 1;
                                strongSelf.input3Button.alpha = 1;
                            } else {
                                strongSelf.onImage.alpha = 1;
                                strongSelf.offImage.alpha = 1;
                                strongSelf.powerImage.alpha = 1;
                                strongSelf.volumeUpImage.alpha = 1;
                                strongSelf.volumeDownImage.alpha = 1;
                            }
                        } completion:^(BOOL finished) {
                            if (finished && !weakBlock.isCancelled) {
                                
                                TodayView *strongSelf = weakSelf;
                                
                                strongSelf.animationsQueue = [NSOperationQueue new];
                                strongSelf.animationsQueue.maxConcurrentOperationCount = 1;
                                strongSelf.showingPowerAndVolume = !showingPowerAndVolume;
                                
                            }
                        }];
                    });
                }
            }];
            
        });
    }];
    [self.animationsQueue addOperation:blockOperation];
}

#pragma mark - 
#pragma mark - Responder Chain Actions

- (void)powerOnAction {
    if ([self.delegate respondsToSelector:@selector(powerOnAction)]) {
        [self.delegate powerOnAction];
    }
}

- (void)powerOffAction {
    if ([self.delegate respondsToSelector:@selector(powerOffAction)]) {
        [self.delegate powerOffAction];
    }
}


- (void)volumeUpAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(volumeUpAction)]) {
        [self.delegate performSelector:@selector(volumeUpAction)];
    }
}

- (void)volumeDownAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(volumeDownAction)]) {
        [self.delegate performSelector:@selector(volumeDownAction)];
    }
}

- (void)volumeMuteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(volumeMuteAction)]) {
        [self.delegate performSelector:@selector(volumeMuteAction)];
    }
}

- (void)input1ButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(input1Action)]) {
        [self.delegate performSelector:@selector(input1Action)];
    }
}

- (void)input2ButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(input2Action)]) {
        [self.delegate performSelector:@selector(input2Action)];
    }
}

- (void)input3ButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(input3Action)]) {
        [self.delegate performSelector:@selector(input3Action)];
    }
}

@end
