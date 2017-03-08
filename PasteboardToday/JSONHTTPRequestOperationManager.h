//
//  JSONHTTPRequestOperationManager.h
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 10/7/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface JSONHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (JSONHTTPRequestOperationManager *)sharedJSONHTTPClient;

@end
