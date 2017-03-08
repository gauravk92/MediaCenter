//
//  TodayView.h
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/11/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TodayViewDelegate <NSObject>

- (void)powerOnAction;
- (void)powerOffAction;
- (void)volumeUpAction;
- (void)volumeDownAction;
- (void)volumeMuteAction;
- (void)input1Action;
- (void)input2Action;
- (void)input3Action;

@end

@interface TodayView : UIVisualEffectView

@property (nonatomic, weak) id<TodayViewDelegate> delegate;

- (void)showConnecting;
- (void)showConnected;
- (void)showPowerOn;
- (void)showPowerOff;
- (void)showError;
- (void)showPoweredOff;
- (void)showRetrying;
- (void)showUnreachable;

@end
