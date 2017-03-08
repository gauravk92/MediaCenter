//
//  PayloadData.h
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/28/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const PayloadDataKeyCommandPowerOn;
NSString *const PayloadDataKeyCommandPowerOff;

NSString *const PayloadDataKeyCommandVolumeUp;
NSString *const PayloadDataKeyCommandVolumeDown;
NSString *const PayloadDataKeyCommandVolumeMute;

// hdmi inputs
NSString *const PayloadDataKeyCommandInputOne;
NSString *const PayloadDataKeyCommandInputTwo;
NSString *const PayloadDataKeyCommandInputThree;
NSString *const PayloadDataKeyCommandSourceMenu;
NSString *const PayloadDataKeyCommandUp;
NSString *const PayloadDataKeyCommandDown;
NSString *const PayloadDataKeyCommandHDMISource;

@interface PayloadData : NSObject

+ (id)fetchSSIDInfo;
+ (NSString*)appString;
+ (NSData*)message;
+ (NSData*)chunkOne;
+ (NSData*)chunkTwoWithCommand:(NSString*)cmd;

@end
