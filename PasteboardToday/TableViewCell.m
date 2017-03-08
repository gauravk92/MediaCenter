//
//  TableViewCell.m
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/27/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "TableViewCell.h"
#import "GCDAsyncSocket.h"
#import "PayloadData.h"

#define  WWW_PORT 55000  // 0 => automatic
#define  WWW_HOST @"10.0.0.200"
#define CERT_HOST @"www.amazon.com"
#define TIMEOUT 5000

#define USE_SECURE_CONNECTION    0
#define USE_CFSTREAM_FOR_TLS     0 // Use old-school CFStream style technique
#define MANUALLY_EVALUATE_TRUST  1

#define READ_HEADER_LINE_BY_LINE 0


@interface TableViewCell () <UIGestureRecognizerDelegate>


@end

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setup {
    self.userInteractionEnabled = YES;
    self.contentView.userInteractionEnabled = YES;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];
    
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];

    UILabel *powerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    powerLabel.text = @"-";
    powerLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    powerLabel.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:powerLabel];
    self.powerState = powerLabel;
    
    self.volumeUp = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.volumeUp setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self.volumeUp setBackgroundImage:[self imageWithColor:[UIColor colorWithWhite:0.7 alpha:0.3]] forState:UIControlStateHighlighted];
    [self.volumeUp setTitle:@"Volume Up" forState:UIControlStateNormal];
    [self.volumeUp addTarget:self action:@selector(volumeUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.volumeUp];
    
    self.volumeDown = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.volumeDown setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self.volumeDown setBackgroundImage:[self imageWithColor:[UIColor colorWithWhite:0.7 alpha:0.3]] forState:UIControlStateHighlighted];
    [self.volumeDown setTitle:@"Volume Down" forState:UIControlStateNormal];
    [self.volumeDown addTarget:self action:@selector(volumeDownAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.volumeDown];

    self.separatorInset = UIEdgeInsetsZero;

    
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)volumeUpAction:(id)sender {
    //[self.volumeDown setTitle:@"Downing" forState:UIControlStateNormal];
    //self.volumeDown.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    NSLog(@"hey");
    //[self startSocket];
}

- (void)volumeDownAction:(id)sender {
    //[self startSocket];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.textLabel sizeToFit];
    [self.powerState sizeToFit];
    [self.volumeUp sizeToFit];
    [self.volumeDown sizeToFit];
    
    self.selectedBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, 50);
    self.textLabel.frame = CGRectMake(20, 12, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.powerState.frame = CGRectMake(20, 30, self.powerState.frame.size.width, self.powerState.frame.size.height);
    self.volumeUp.frame = CGRectMake(0, 50, self.frame.size.width/2, 50);
    self.volumeDown.frame = CGRectMake(self.volumeUp.frame.size.width, 50, self.frame.size.width/2, 50);
}

//
//- (void)awakeFromNib {
//    // Initialization code
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





@end
