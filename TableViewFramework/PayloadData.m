//
//  PayloadData.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/28/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "PayloadData.h"
#import "GTMStringEncoding.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define  WWW_PORT 55000  // 0 => automatic
#define  WWW_HOST @"127.0.0.1"
#define CERT_HOST @"www.amazon.com"
#define MAC_ADDR @"00:00:00:00"
#define SERV_NAME @"NodeJS Samsung Remote"
#define APP_STRING @"iphone..iapp.samsung"
#define TV_STRING @"iphone.UN60D6000.iapp.samsung"
#define TIMEOUT 5000



NSString *const PayloadDataKeyCommandPowerOn = @"KEY_POWER";
NSString *const PayloadDataKeyCommandPowerOff = @"KEY_POWEROFF";

NSString *const PayloadDataKeyCommandVolumeUp = @"KEY_VOLUP";
NSString *const PayloadDataKeyCommandVolumeDown = @"KEY_VOLDOWN";
NSString *const PayloadDataKeyCommandVolumeMute = @"KEY_MUTE";

// hdmi inputs
NSString *const PayloadDataKeyCommandInputOne = @"KEY_HDMI";
NSString *const PayloadDataKeyCommandInputTwo = @"KEY_DVI";
NSString *const PayloadDataKeyCommandInputThree = @"KEY_HDMI1";
NSString *const PayloadDataKeyCommandSourceMenu = @"KEY_SOURCE";
NSString *const PayloadDataKeyCommandUp = @"KEY_UP";
NSString *const PayloadDataKeyCommandDown = @"KEY_DOWN";
NSString *const PayloadDataKeyCommandHDMISource = @"KEY_HDMI";

static const unsigned char zeroByte = 0;

const NSStringEncoding dataEncoding = NSUTF8StringEncoding;

@implementation PayloadData

+ (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge NSArray*)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}

+ (NSString*)appString {
    return APP_STRING;
}

+ (NSData*)message {
    NSDataBase64EncodingOptions opt = 0;
    
    NSData *ipData = [WWW_HOST dataUsingEncoding:dataEncoding];
    NSData *ipEncode = [ipData base64EncodedDataWithOptions:opt];
    NSUInteger ipLength = ipEncode.length;
    NSNumber *ipLengthNum = [NSNumber numberWithUnsignedInteger:ipLength];
    unsigned char ipLengthChar = [ipLengthNum unsignedCharValue];
    
    NSData *macData = [MAC_ADDR dataUsingEncoding:dataEncoding];
    NSData *macEncode = [macData base64EncodedDataWithOptions:opt];
    NSUInteger macLength = macEncode.length;
    NSNumber *macNum = [NSNumber numberWithUnsignedInteger:macLength];
    unsigned char macLengthChar = [macNum unsignedCharValue];
    
    NSData *hostData = [SERV_NAME dataUsingEncoding:dataEncoding];
    NSData *hostEncode = [hostData base64EncodedDataWithOptions:opt];
    NSUInteger hostLength = hostEncode.length;
    NSNumber *hostNum = [NSNumber numberWithUnsignedInteger:hostLength];
    unsigned char hostLengthChar = [hostNum unsignedCharValue];
    
    unsigned char dByte = 0x64;
    NSMutableData *message = [[NSMutableData alloc] init];
    [message appendBytes:&dByte length:1];
    [message appendBytes:&zeroByte length:1];
    [message appendBytes:&ipLengthChar length:sizeof(ipLengthChar)];
    [message appendBytes:&zeroByte length:1];
    [message appendData:ipEncode];
    [message appendBytes:&macLengthChar length:sizeof(macLengthChar)];
    [message appendBytes:&zeroByte length:1];
    [message appendData:macEncode];
    [message appendBytes:&hostLengthChar length:sizeof(hostLengthChar)];
    [message appendBytes:&zeroByte length:1];
    [message appendData:hostEncode];
    return message;
}

+ (NSData*)chunkOne {
    
    NSData *message = [PayloadData message];
    
    NSData *appData = [APP_STRING dataUsingEncoding:dataEncoding];
    NSUInteger appLength = appData.length;
    unsigned char appLengthChar = [[NSNumber numberWithUnsignedInteger:appLength] unsignedCharValue];
    

    NSUInteger msgLength = message.length;
    unsigned char msgLengthChar = [[NSNumber numberWithUnsignedInteger:msgLength] unsignedCharValue];
    
    NSMutableData *payload = [[NSMutableData alloc] init];
    [payload appendBytes:&zeroByte length:1];
    [payload appendBytes:&appLengthChar length:sizeof(appLengthChar)];
    [payload appendBytes:&zeroByte length:1];
    [payload appendData:appData];
    [payload appendBytes:&msgLengthChar length:sizeof(msgLengthChar)];
    [payload appendBytes:&zeroByte length:1];
    [payload appendData:message];
    return [NSData dataWithData:payload];
}

+ (NSData*)chunkTwoWithCommand:(NSString*)cmd; {
    
    NSData *cmdData = [cmd dataUsingEncoding:dataEncoding];
    NSData *cmdEncode = [cmdData base64EncodedDataWithOptions:0];
    NSUInteger cmdLength = cmdEncode.length;
    unsigned char cmdLengthChar = [[NSNumber numberWithUnsignedInteger:cmdLength] unsignedCharValue];
    
    NSMutableData *message = [[NSMutableData alloc] init];
    [message appendBytes:&zeroByte length:1];
    [message appendBytes:&zeroByte length:1];
    [message appendBytes:&zeroByte length:1];
    [message appendBytes:&cmdLengthChar length:sizeof(cmdLengthChar)];
    [message appendBytes:&zeroByte length:1];
    [message appendData:cmdEncode];
    
    NSData *tvString = [TV_STRING dataUsingEncoding:dataEncoding];
    NSUInteger tvLength = tvString.length;
    unsigned char tvLengthChar = [[NSNumber numberWithUnsignedInteger:tvLength] unsignedCharValue];
    
    NSUInteger msgLength = message.length;
    unsigned char msgLengthChar = [[NSNumber numberWithUnsignedInteger:msgLength] unsignedCharValue];
    
    NSMutableData *payload = [[NSMutableData alloc] init];
    [payload appendBytes:&zeroByte length:1];
    [payload appendBytes:&tvLengthChar length:sizeof(tvLengthChar)];
    [payload appendBytes:&zeroByte length:1];
    [payload appendData:tvString];
    [payload appendBytes:&msgLengthChar length:sizeof(msgLengthChar)];
    [payload appendBytes:&zeroByte length:1];
    [payload appendData:message];
    
    return [NSData dataWithData:payload];
    
}

@end
