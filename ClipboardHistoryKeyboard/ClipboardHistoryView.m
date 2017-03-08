//
//  ClipboardHistoryView.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 8/19/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "ClipboardHistoryView.h"
#import <CoreText/CoreText.h>

static inline CGFLOAT_TYPE cground(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

@interface ClipboardHistoryLayer : CALayer

@end

@implementation ClipboardHistoryLayer

//- (void)drawInContext:(CGContextRef)context {
//
//    CGRect clippingRect = self.bounds;
//    CGContextClipToRect(context, clippingRect);
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, clippingRect);
//    CGFloat contextHeight = clippingRect.size.height;
//    CGContextTranslateCTM(context, 0.0f, contextHeight);
//    CGContextScaleCTM(context, 1.0f, -1.0f);
//
//
//
//    //        CGRect scrollOffsetFrame = CGRectMake(self.scrollView.contentOffset.x, 0, self.frame.size.width, self.scrollView.frame.size.height);
//    //        if (!CGRectIntersectsRect(scrollOffsetFrame, clippingRect)) {
//    //            return;
//    //        }
//
//    UIFont *titleNormalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];
//    UIColor *titleNormalColor = [UIColor colorWithWhite:0.2 alpha:1.0];
//
//
//
//
//    CFStringRef string = (__bridge_retained CFStringRef)@"helloo world";
//    CTFontRef font = CTFontCreateWithName((CFStringRef)[titleNormalFont fontName], [titleNormalFont pointSize], NULL);
//    // Initialize the string, font, and context
//
//    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName};
//    CFTypeRef values[] = { font, titleNormalColor.CGColor};
//
//    CFDictionaryRef attributes =
//    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
//                       (const void**)&values, sizeof(keys) / sizeof(keys[0]),
//                       &kCFTypeDictionaryKeyCallBacks,
//                       &kCFTypeDictionaryValueCallBacks);
//
//    CFAttributedStringRef attrString =
//    CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
//
//    CFBridgingRelease(attributes);
//
//    CTLineRef line = CTLineCreateWithAttributedString(attrString);
//    CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
//    CGFloat lineHeight = 0;
//    if (lineBounds.size.height > 0) {
//        lineHeight = lineBounds.size.height;
//    }
//
//    // Set text position and draw the line into the graphics context
//    CGContextSetTextPosition(context, 10.0, cground(contextHeight - lineHeight));
//
//    //    if (![self.displayTableView cellForRowAtIndexPath:self.sectionIndexPath]) {
//    //        DLogObject(self.sectionIndexPath);
//    //        return;
//    //    }
//
//    CTLineDraw(line, context);
//
//
//
//
//    CFBridgingRelease(line);
//    CFBridgingRelease(string);
//}
//
//-(void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx
//{
//    CGRect dirtyRect = CGContextGetClipBoundingBox(ctx);
//    // draw!
//
//    [[UIColor redColor] setFill];
//    CGContextFillRect(ctx, dirtyRect);
//
//}


@end

@implementation ClipboardHistoryView

+ (Class)layerClass {
    return [ClipboardHistoryLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    CGFloat bottomToolbarHeight = 50;
//    CGFloat bottomToolbarY = self.bounds.size.height - bottomToolbarHeight;
//
//    self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, bottomToolbarY);
//
//    self.button.frame = CGRectMake(0, bottomToolbarY, 100, bottomToolbarHeight);
//    
    self.tableView.frame = self.frame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
