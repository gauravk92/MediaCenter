//
//  TimerOperation.h
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 10/2/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//
// http://stackoverflow.com/questions/5476972/nstimer-in-nsoperation-main-method

#import <Foundation/Foundation.h>

@interface TimerOperation : NSOperation {
@private
    NSTimer* _timer;
}

@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isFinished;

@end