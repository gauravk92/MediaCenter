//
//  TimerOperation.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 10/2/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "TimerOperation.h"

@implementation TimerOperation

@synthesize isExecuting = _executing;
@synthesize isFinished  = _finished;

- (instancetype)init {
    self = [super init];
    if (self) {
        _executing = NO;
        _finished  = NO;
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)finish {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)start {
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    } else {
        [self willChangeValueForKey:@"isExecuting"];
        [self performSelectorOnMainThread:@selector(main)
                               withObject:nil
                            waitUntilDone:NO];
        _executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)timerFired:(NSTimer*)timer {
    if (![self isCancelled]) {
        // Whatever you want to do when the timer fires
    }
}

- (void) main {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(timerFired:)
                                             userInfo:nil
                                              repeats:YES];
}

- (void) cancel {
    [_timer invalidate];
    [super cancel];
}

@end