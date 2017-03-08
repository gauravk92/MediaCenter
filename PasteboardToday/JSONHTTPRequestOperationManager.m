//
//  JSONHTTPRequestOperationManager.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 10/7/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "JSONHTTPRequestOperationManager.h"

@implementation JSONHTTPRequestOperationManager

+ (JSONHTTPRequestOperationManager *)sharedJSONHTTPClient
{
    static JSONHTTPRequestOperationManager *_sharedHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost"]];
    });
    
    return _sharedHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.requestSerializer = requestSerializer;
    }
    
    return self;
}

@end
