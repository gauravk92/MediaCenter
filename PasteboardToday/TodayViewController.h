//
//  TodayViewController.h
//  PasteboardToday
//
//  Created by Gaurav Khanna on 9/11/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TodayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *pasteboard;
@property (weak, nonatomic) IBOutlet UILabel *pasteboardText;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
