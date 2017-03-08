//
//  TableViewCell.h
//  ClipboardHistory
//
//  Created by Gaurav Khanna on 9/27/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *powerHighlight;
@property (nonatomic, strong) UILabel *powerState;
@property (nonatomic, strong) UIButton *volumeUp;
@property (nonatomic, strong) UIButton *volumeDown;

- (NSData*)chunkOne;
- (NSData*)chunkTwo;

@end
