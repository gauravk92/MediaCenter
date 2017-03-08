//
//  KeyboardViewController.m
//  ClipboardHistoryKeyboard
//
//  Created by Gaurav Khanna on 8/19/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "KeyboardViewController.h"
#import "ClipboardHistoryView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "uzysViewController.h"

NSString *const CHKeyboardTableViewCell = @"CHKeyboardTableViewCell";

@interface KeyboardViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ClipboardHistoryView *view;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

//- (void)loadView {
//    self.view = [[ClipboardHistoryView alloc] initWithFrame:CGRectZero];
//}

- (NSDictionary*) logMetaDataFromImage:(UIImage*)image
{
    NSData *jpeg = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    NSLog (@"imageMetaData %@",imageMetaData);
    return (__bridge NSDictionary*)imageMetaData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.view.autoresizesSubviews = YES;
    
    
    UIImage *image = [UIImage new];
    self.items = [[UIPasteboard generalPasteboard] items];
    //self.items = @[@"hello, world", @"http://link.me", image];
    //[[UIPasteboard generalPasteboard] addItems:self.items];
    
    
    
    // Perform custom UI setup here
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //[self.nextKeyboardButton setTitle:[NSLocalizedString(@"NEXT", @"Title for 'Next Keyboard' button") uppercaseString] forState:UIControlStateNormal];
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.218 alpha:1.000], NSBackgroundColorAttributeName: [UIColor whiteColor]};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"NEXT" attributes:attrs];
    [self.nextKeyboardButton setAttributedTitle:string forState:UIControlStateNormal];
    self.nextKeyboardButton.backgroundColor = [UIColor whiteColor];
    [self.nextKeyboardButton sizeToFit];
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    //self.view.button = self.nextKeyboardButton;
    
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    
//    uzysViewController *viewC = [[uzysViewController alloc] initWithNibName:nil bundle:nil];
//    [self.view addSubview:viewC.view];
//    viewC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    viewC.view.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addChildViewController:viewC];
//    [viewC didMoveToParentViewController:self];
    
    //[self.textDocumentProxy insertText:@"]
   
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
//    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.scrollView.delegate = self;
//    self.scrollView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.scrollView];
//    
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
//    self.tableView.rowHeight = 60;
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    self.tableView.separatorColor = [UIColor colorWithWhite:0.804 alpha:1.000];
//    NSArray *items = [[UIPasteboard generalPasteboard] items];
//    
//    
//    
//    [self.inputView addSubview:self.tableView];
//    //self.view.tableView = self.tableView;
    
    //NSLayoutConstraint *tableViewHeight = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    //NSLayoutConstraint *tableViewWidth = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    //[self.view addConstraints:@[tableViewHeight, tableViewWidth]];
//
//    NSLayoutConstraint *tableViewLeftSideConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
//    NSLayoutConstraint *tableViewTopSideConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
//    NSLayoutConstraint *tableViewRightSideConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
//    NSLayoutConstraint *tableViewBottomSideConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
//    [self.view addConstraints:@[tableViewLeftSideConstraint, tableViewTopSideConstraint, tableViewRightSideConstraint, tableViewBottomSideConstraint]];
//
    
    
    //[self.view addSubview:self.nextKeyboardButton];
//    NSLayoutConstraint *nextKeyboardButtonLeftSideConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20.0];
//    NSLayoutConstraint *nextKeyboardButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0];
//    [self.view addConstraints:@[nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint]];

    //[self.tableView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat bottomToolbarHeight = 50;
    CGFloat bottomToolbarY = self.view.frame.size.height - bottomToolbarHeight;
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, bottomToolbarY);

    self.nextKeyboardButton.frame = CGRectMake(0, bottomToolbarY, 100, bottomToolbarHeight);
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    UIImage *image = [[UIImage alloc] init];
//    
//    
//    
//    //NSLog(@"viewWillAppear");
//    //[self.tableView reloadData];
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    //NSLog(@"viewDidAppear");
//    //[self.tableView reloadData];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count]+1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.tableView.rowHeight;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0) {
//        return 50;
//    }
//    return self.tableView.rowHeight;
//}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CHKeyboardTableViewCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CHKeyboardTableViewCell];
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    cell.imageView.frame = CGRectMake(0, 0, 60, 100);
    cell.imageView.image = nil;
    cell.imageView.layer.shouldRasterize = YES;
    cell.imageView.layer.rasterizationScale = scale;
    cell.textLabel.text = nil;
    cell.textLabel.layer.shouldRasterize = YES;
    cell.textLabel.layer.rasterizationScale = scale;
    cell.detailTextLabel.text = nil;
    cell.detailTextLabel.layer.shouldRasterize = YES;
    cell.detailTextLabel.layer.rasterizationScale = scale;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = scale;
    cell.contentView.layer.shouldRasterize = YES;
    cell.contentView.layer.rasterizationScale = scale;
    
//    if (indexPath.row == 0) {
//        cell.textLabel.text = @"Search";
//        
//    } else {
    
        NSArray *items = self.items;
        NSObject *item = nil;
        CGFloat indexRow = indexPath.row;
        if (indexRow < items.count) {
            item = [items objectAtIndex:indexRow];
        }
        NSArray *keys = nil;
        if ([item respondsToSelector:@selector(allKeys)]) {
            keys = [item performSelector:@selector(allKeys)];
        }
        NSString *keyType = nil;
        if ([keys count] > 0) {
            keyType = [keys objectAtIndex:0];
        }
        NSObject *val = nil;
        if ([item respondsToSelector:@selector(objectForKey:)]) {
            val = [item performSelector:@selector(objectForKey:) withObject:keyType];
        }
        
        CFStringRef keyTypeRef = (__bridge CFStringRef)keyType;
        
        if (UTTypeConformsTo(keyTypeRef, kUTTypeText)) {
            NSString *string = (NSString*)val;
            cell.textLabel.text = string;
            cell.imageView.image = [UIImage imageNamed:@"texticon"];
        }
        if (UTTypeConformsTo(keyTypeRef, kUTTypeImage)) {
            UIImage *image = (UIImage*)val;
            cell.imageView.image = image;
        }
//    }
    cell.imageView.frame = CGRectMake(0, 0, 60, 100);
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.

    //NSLog(@"textWillChange");
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
    
    //NSLog(@"textdidChange");
    //[self.tableView reloadData];
}

@end
