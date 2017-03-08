//
//  URLEncode.h
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/28/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLCoder)

- (NSString*)urlencode;
- (NSString*)urldecode;

@end

@interface NSData (URLCoder)

- (NSString*)urlEncode;

@end

//@interface NSData (NSData_URLEncode)
//
//- (NSString *)encodeForURL;
//- (NSString *)stringWithoutURLEncoding;
//- (NSString *)encodeForOauthBaseString;
//
//@end