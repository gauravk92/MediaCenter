//
//  EncodeTest.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/27/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "TableViewCell.h"


@implementation NSString (NSString_Extended)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end

@interface EncodeTest : XCTestCase

@property (nonatomic, strong) TableViewCell *cell;

@end

@implementation EncodeTest


- (void)setUp {
    [super setUp];
    self.cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testid"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    
    NSData *payload = [self.cell chunkOne];
    NSString *chunkOne = [NSString stringWithCString:chunkOne.bytes encoding:NSUTF8StringEncoding];
    
    NSString *oneEncode = [chunkOne urlencode];

    NSString *ass = @"%00%14%00iphone..iapp.samsung@%00d%00%0C%00MTI3LjAuMC4x%10%00MDA6MDA6MDA6MDA=%1C%00Tm9kZUpTIFNhbXN1bmcgUmVtb3Rl"; // \n
    NSString *two = @"%00%1D%00iphone.UN60D6000.iapp.samsung%15%00%00%00%00%10%00S0VZX1BPV0VST0ZG"; // \n
    
    XCTAssert([oneEncode isEqualToString:ass], @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
