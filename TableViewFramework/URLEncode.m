//
//  URLEncode.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/28/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "URLEncode.h"

@implementation NSString (URLCoder)

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

- (NSString*)urldecode {
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (__bridge CFStringRef)self,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}

@end

#define IsUrlSafe(CHAR)                                     \
((CHAR) >= '0' && (CHAR) <= '9') \
|| ((CHAR) >= 'a' && (CHAR) <= 'z') \
|| ((CHAR) >= 'A' && (CHAR) <= 'Z')

@implementation NSData (URLEncode)

- (NSString *)urlEncode
{
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return [string urlencode];
    
//    NSMutableString *urlEncoded = [NSMutableString new];
//    const char* bytes = self.bytes;
//    for (int i=0 ; i<self.length ; i++) {
//        const char byte = bytes[i];
//        if (IsUrlSafe(byte)) {
//            [urlEncoded appendFormat:@"%c", byte];
//        } else {
//            [urlEncoded appendFormat:@"%%%02x", byte];
//        }
//    }
//    return urlEncoded;
}

@end

//
//@implementation NSData (NSData_URLEncode)
//- (NSString *) stringWithoutURLEncoding {
//    NSString *hexDataDesc = [self description];
//    hexDataDesc = [[hexDataDesc stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSMutableString * newString = [NSMutableString string];
//    for (int x=0; x<[hexDataDesc length]; x+=2) {
//        NSString *component = [hexDataDesc substringWithRange:NSMakeRange(x, 2)];
//        int value = 0;
//        sscanf([component cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
//        if ((value <=46 && value >= 45) || (value <=57 && value >= 48) || (value <=90 && value >= 65) || (value == 95) || (value <=122 && value >= 97)) {  //48-57, 65-90, 97-122
//            [newString appendFormat:@"%c", (char)value];
//        }
//        else {
//            [newString appendFormat:@"%%%@", [component uppercaseString]];
//        }
//    }
//    NSString *aNewString = [newString stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
//    return aNewString;
//}
//- (NSString *) encodeForURL {
//    NSString *newString = [self stringWithoutURLEncoding];
//    newString = [newString stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
//    const CFStringRef legalURLCharactersToBeEscaped = CFSTR("!*'();:@&=+$,/?#[]<>\"{}|\\`^% ");
//    NSString *urlEncodedString = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)newString, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8);
//    return urlEncodedString;
//}
//- (NSString *) encodeForOauthBaseString {
//    NSString *newString = [self encodeForURL];
//    newString =[newString stringByReplacingOccurrencesOfString:@"%257E" withString:@"~"];
//    return newString;
//}
//@end
