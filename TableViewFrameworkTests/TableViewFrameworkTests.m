//
//  TableViewFrameworkTests.m
//  TableViewFrameworkTests
//
//  Created by Gaurav Khanna on 9/27/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PayloadData.h"
#import "URLEncode.h"
#import <WebKit/WebKit.h>
#import "Reachability.h"


@interface TableViewFrameworkTests : XCTestCase

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation TableViewFrameworkTests



- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSString *scriptString = @"Some javascript";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:script];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLengthEncode {
    
    NSString *appString = [PayloadData appString];
    NSData *appData = [appString dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger appLength = appData.length;
    NSLog(@"data: %@", appData);
    
    NSData *appUni = [appString dataUsingEncoding:NSUnicodeStringEncoding];
    NSUInteger uniLength = appUni.length;
    NSLog(@"uni data: %@", appUni);
    
    NSData *appU16 = [appString dataUsingEncoding:NSUTF16StringEncoding];
    NSUInteger u16length = appU16.length;
    NSLog(@"uni16 data: %@", appU16);
    
    NSString *baseTest = @"FA=="; // btoa(String.fromCharCode(20));
    
    NSMutableData *data = [NSMutableData new];
    [data appendBytes:&appLength length:sizeof(appLength)];
    
    NSData *dataConv = [[NSData alloc] initWithBase64EncodedString:baseTest options:0];
    
    NSLog(@"dataConv: %@", dataConv);
    
    char cString = 20;
    char cStringHex = 0x14;
    NSData *cStringTest = [[NSData alloc] initWithBytes:&cString length:sizeof(cString)];
    
    //NSString *tmp = [NSString stringWithFormat:@"%ld", appLength];
    //const char *str = [tmp UTF8String];
    //size_t length = [tmp length];
    
    NSNumber *num = [NSNumber numberWithUnsignedInteger:appLength];
    char numChar = [num charValue];
    NSData *sizeTest = [[NSData alloc] initWithBytes:&numChar length:sizeof(numChar)];
    
    XCTAssert([sizeTest isEqualToData:dataConv], @"Pass");
    NSLog(@"sizeTest: %@", sizeTest);
    
    //XCTAssert([cStringTest isEqualToData:dataConv], @"Pass");
    //NSLog(@"cStringTest %@", cStringTest);
    
    //char cString[] = "\u0014";
    //NSData *dataStraightTest = [NSData dataWithBytes:cString length:strlen(cString)];
    
    //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSLog(@"result string: %@", string);
    
    NSData *dataTest = [data base64EncodedDataWithOptions:0];
    //XCTAssert([dataConv isEqualToData:dataTest], @"Pass");
    NSLog(@"dataTest: %@", dataTest);
    
    //NSLog(@"unicode test: %@", @"\U00140000");
    
    
    //NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSString *appEncode = [appData urlEncode];
    
    
//    
//    NSLog(@"encoding %@", appEncode);
//    
//    XCTestExpectation *expect = [self expectationWithDescription:@"evald"];
//    
//    NSString *script = [NSString stringWithFormat:@"encodeURI(\"%@\")", appString];
//    
//    [self.webView evaluateJavaScript:script completionHandler:^(id obj, NSError *err) {
//        
//        NSLog(@"obj %@", obj);
//        NSLog(@"err %@", err);
//        
//        XCTAssert([appEncode isEqualToString:obj], @"Pass");
//        
//        [expect fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
//        NSLog(@"err %@", error);
//    }];
//    
    
}

- (void)testControlExample {
    NSString *baseTest = @"ZA==";
    
    unsigned char aChar = 'd';
    NSData *data = [[NSData alloc] initWithBytes:&aChar length:sizeof(aChar)];
    
    NSString *str = [data base64EncodedStringWithOptions:0];
    
    XCTAssert([str isEqualToString:baseTest], @"Pass");
    NSLog(@"str %@", str);
}

- (void)testControlExample2 {
    NSString *baseTest = @"d";
    
    unsigned char char64 = 0x64;
    NSData *data64 = [NSData dataWithBytes:&char64 length:sizeof(char64)];
    NSLog(@"data64: %@", data64);
    
    unsigned char aChar = 'd';
    
    NSData *data = [[NSData alloc] initWithBytes:&aChar length:sizeof(aChar)];
    NSLog(@"data %@", data);
    
    //NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    //XCTAssert([str isEqualToString:baseTest], @"Pass");
    //NSLog(@"str %@", str);
    
}



- (void)testEncodingIPLength {
    // 12
    unsigned char ipLength = 12;
    NSString *dataString = @"12";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"DA==";
    
    XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    NSLog(@"dataBase %@", dataBase);
}

- (void)testEncodingMacLength {
    //16
    NSString *dataString = @"16";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"EA==";
    
    XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    NSLog(@"dataBase %@", dataBase);
}

- (void)testEncodingHostLength {
    //28
    NSString *dataString = @"28";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"HA==";
    
    XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    NSLog(@"dataBase %@", dataBase);
}

- (void)testEncodingData {
    NSString *dataString = @"iphone..iapp.samsung";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"aXBob25lLi5pYXBwLnNhbXN1bmc=";
    
    XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    NSLog(@"dataBase %@", dataBase);
}

- (void)testEncodingDataHost {
    NSString *dataString = @"iphone.UN60D6000.iapp.samsung";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"aXBob25lLlVONjBENjAwMC5pYXBwLnNhbXN1bmc=";
    
    XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    NSLog(@"dataBase %@", dataBase);
}

- (void)testEncodingDataMac {
    NSString *dataString = @"00:00:00:00";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"MDA6MDA6MDA6MDA=";
    
    XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    NSLog(@"dataBase %@", dataBase);
}

- (void)testEncodingDataIPLength {
    NSString *dataString = @"10.0.0.200";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"MTAuMC4wLjIwMA==";
    
    
    
    //XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    //NSLog(@"dataBase %@", dataBase);
}

- (void)testEncodingDataIP {
    NSString *dataString = @"10.0.0.200";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataBase = [data base64EncodedStringWithOptions:0];
    
    NSString *baseTest = @"MTAuMC4wLjIwMA==";
    
    XCTAssert([baseTest isEqualToString:dataBase], @"Pass");
    NSLog(@"dataBase %@", dataBase);
}

- (void)testMessage {
    
    NSString *baseTest = @"ZAAMAE1USTNMakF1TUM0eBAATURBNk1EQTZNREE2TURBPRwAVG05a1pVcFRJRk5oYlhOMWJtY2dVbVZ0YjNSbA==";
    //NSString *baseTest = @"d\u0000\f\u0000MTI3LjAuMC4x\u0010\u0000MDA6MDA6MDA6MDA=\u001c\u0000Tm9kZUpTIFNhbXN1bmcgUmVtb3Rl";
    
    NSData *message = [PayloadData message];
    
    NSString *baseString = [message base64EncodedStringWithOptions:0];
    
    XCTAssert([baseTest isEqualToString:baseString], @"Pass");
    NSLog(@"baseString %@", baseString);
    
}

- (void)testExample {
    
    //XCTestExpectation *expect = [self expectationWithDescription:@"evald"];
    
    NSData *chunkOne = [PayloadData chunkOne];
    
    
    NSString *payload = [chunkOne base64EncodedStringWithOptions:0];
    NSLog(@"chunk %@", payload);
    NSString *oneEncode = [chunkOne urlEncode];
    NSLog(@"enc %@", oneEncode);
    
    
    NSString *one = @"iphone..iapp.samsung@d \
    MTI3LjAuMC4xMDA6MDA6MDA6MDA=Tm9kZUpTIFNhbXN1bmcgUmVtb3Rl";
    NSString *oneURI = @"%00%14%00iphone..iapp.samsung@%00d%00%0C%00MTI3LjAuMC4x%10%00MDA6MDA6MDA6MDA=%1C%00Tm9kZUpTIFNhbXN1bmcgUmVtb3Rl"; // \n
    NSString *oneBase = @"ABQAaXBob25lLi5pYXBwLnNhbXN1bmdAAGQADABNVEkzTGpBdU1DNHgQAE1EQTZNREE2TURBNk1EQT0cAFRtOWtaVXBUSUZOaGJYTjFibWNnVW1WdGIzUmw=";
    //NSString *oneUni = @"\u0000\u0014\u0000iphone..iapp.samsung@\u0000d\u0000\f\u0000MTI3LjAuMC4x\u0010\u0000MDA6MDA6MDA6MDA=\u001c\u0000Tm9kZUpTIFNhbXN1bmcgUmVtb3Rl";
    
    //XCTAssert([oneEncode isEqualToString:oneURI], @"Pass");
    XCTAssert([payload isEqualToString:oneBase], @"Pass");
    
//    NSString *evalString = [NSString stringWithFormat:@"encodeURI(\"%@\")", ]
//    [self.webView evaluateJavaScript: completionHandler:<#^(id, NSError *)completionHandler#>]

}

- (void)testExample2 {
    
    NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandPowerOff];
    
    NSString *payload = [chunkTwo base64EncodedStringWithOptions:0];
    NSLog(@"CHUNK TWO %@", payload);
    NSString *encode = [chunkTwo urlEncode];
    NSLog(@"TWO ENCODE %@", encode);
    
    NSString *two = @"iphone.UN60D6000.iapp.samsungS0VZX1BPV0VST0ZG";
    NSString *twoURI = @"%00%1D%00iphone.UN60D6000.iapp.samsung%15%00%00%00%00%10%00S0VZX1BPV0VST0ZG"; // \n
    NSString *twoBase = @"AB0AaXBob25lLlVONjBENjAwMC5pYXBwLnNhbXN1bmcVAAAAABAAUzBWWlgxQlBWMFZTVDBaRw==";
    //NSString *twoUni = @"\u0000\u001d\u0000iphone.UN60D6000.iapp.samsung\u0015\u0000\u0000\u0000\u0000\u0010\u0000S0VZX1BPV0VST0ZG";
    
    //XCTAssert([encode isEqualToString:twoURI]);
    XCTAssert([payload isEqualToString:twoBase]);
}

- (void)testDataEncoding {
    
    NSString *appString = [PayloadData appString];
    NSData *appData = [appString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *appEncode = [appData urlEncode];
    
    NSLog(@"encoding %@", appEncode);
    
    XCTestExpectation *expect = [self expectationWithDescription:@"evald"];
    
    NSString *script = [NSString stringWithFormat:@"encodeURI(\"%@\")", appString];
    
    [self.webView evaluateJavaScript:script completionHandler:^(id obj, NSError *err) {
        
        NSLog(@"obj %@", obj);
        NSLog(@"err %@", err);
        
        XCTAssert([appEncode isEqualToString:obj], @"Pass");
        
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"err %@", error);
    }];
    
}

- (void)testStringEncoding {
    
    NSString *appString = [PayloadData appString];
    NSString *encode = [appString urlencode];
    
    XCTestExpectation *expect = [self expectationWithDescription:@"evald"];
    
    NSString *script = [NSString stringWithFormat:@"encodeURI(\"%@\")", appString];
    
    [self.webView evaluateJavaScript:script completionHandler:^(id obj, NSError *err) {
        
        NSLog(@"obj %@", obj);
        NSLog(@"err %@", err);
        
        XCTAssert([encode isEqualToString:obj], @"Pass");
        
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"err %@", error);
    }];
    
}

- (void)testByteEncoding {
    
    //NSMutableData *data = [NSMutableData data];
    unsigned char zeroByte = 0;
    //[data appendBytes:&zeroByte length:1];
    
    char aChar = '0' + zeroByte;
    
    NSString *enc = [[NSString alloc] initWithCString:&aChar encoding:NSUTF8StringEncoding];
    
    NSLog(@"char zerobyte: %c", aChar);
    NSLog(@"string zerobyte: %@", enc);
    NSLog(@"data zerobyte: %@", [NSData dataWithBytes:&aChar length:sizeof(aChar)]);
    
    //NSString *enc = [data urlEncode];
    //NSLog(@"NULL BYTE: %@", enc);
    
    XCTestExpectation *expect = [self expectationWithDescription:@"evald"];
    
    NSString *script = [NSString stringWithFormat:@"encodeURI();"];
    [self.webView evaluateJavaScript:script completionHandler:^(id obj, NSError *err) {
        NSLog(@"obj %@", obj);
        NSLog(@"err %@", err);
        XCTAssert([enc isEqualToString:@"%00"], @"Pass");
        
        [expect fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"err %@", error);
    }];
    
}

- (void)testEncoding {
    
    NSMutableData *data = [NSMutableData data];
    unsigned char zeroByte = 0;
    [data appendBytes:&zeroByte length:1];
    
    NSString *enc = [data urlEncode];
    NSLog(@"NULL BYTE: %@", enc);
    
    XCTestExpectation *expect = [self expectationWithDescription:@"evald"];
    
    
    [self.webView evaluateJavaScript:@"encodeURI(String.fromCharCode(0x00));" completionHandler:^(id obj, NSError *err) {
        NSLog(@"obj %@", obj);
        NSLog(@"err %@", err);
        XCTAssert([enc isEqualToString:obj], @"Pass");
        
        [expect fulfill];

    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"err %@", error);
    }];
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
