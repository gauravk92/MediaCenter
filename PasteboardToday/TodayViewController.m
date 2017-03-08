//
//  TodayViewController.m
//  PasteboardToday
//
//  Created by Gaurav Khanna on 9/11/14.
//  Copyright (c) 2014 gapps. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TodayView.h"
#import "TableViewCell.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PayloadData.h"
#import "GCDAsyncSocket.h"
#import "gdebug.h"
#import "EPPZReachability.h"
#import "JSONHTTPRequestOperationManager.h"
#import "TTTURLRequestFormatter.h"
#import "AFNetworking.h"
#import "AFNetworkActivityLogger.h"
#import <arpa/inet.h>
#import "Reachability.h"
#define  WWW_PORT 55000  // 0 => automatic
#define  WWW_HOST @"10.0.0.200"
#define CERT_HOST @"www.amazon.com"
#define TIMEOUT 5000

#define USE_SECURE_CONNECTION    0
#define USE_CFSTREAM_FOR_TLS     0 // Use old-school CFStream style technique
#define MANUALLY_EVALUATE_TRUST  1

#define READ_HEADER_LINE_BY_LINE 0

NSString *const TableViewCellIdentifier = @"TableViewCellIdentifier";

NSDate *globalTime;

@interface TodayViewController () <NCWidgetProviding, TodayViewDelegate, NSStreamDelegate> {
    NSInputStream *InputStream;
    NSOutputStream *OutputStream;
    NSMutableData *OutputData;
}



@property (nonatomic, strong, readwrite) TodayView *view;
@property (nonatomic, copy) UIColor *pasteNormalColor;
@property (nonatomic, copy) UIColor *pasteHighlightColor;
@property (nonatomic, strong) UILongPressGestureRecognizer *pasteGestureRecognizer;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
//@property (nonatomic, strong) NSInputStream *inputStream;
//@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) NSInteger powerStateAction;
@property (nonatomic, assign) NSInteger powerStateRetry;

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

//@property (nonatomic, strong) Reachability *reach;
//@property (nonatomic, strong) Reachability *castReach;
//@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, assign) BOOL connectionAttempt;

@end

//NSString *post = @"v=000000";
//NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//
//NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
//
//NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//[request setURL:[NSURL URLWithString:@"http://LivingRoom.local:8008/apps/YouTube"]];
//[request setHTTPMethod:@"POST"];
//[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//[request setHTTPBody:postData];
//
//[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//    DLogObject(response);
//    DLogObject(data);
//    DLogObject(connectionError);
//}];


@implementation TodayViewController

+(BOOL)canConnect {
    Reachability *r = [Reachability reachabilityWithHostName:@"10.0.0.200"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    return ((internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN));
}

//*******************************************
//*******************************************
//********** TCP CLIENT INITIALISE **********
//*******************************************
//*******************************************
- (void)TcpClientInitialise
{
    NSLog(@"Tcp Client Initialise");
    
    InputStream = [[NSInputStream alloc] initWithURL:[NSURL URLWithString:@"http://10.0.0.200:55000"]];
    OutputStream = [[NSOutputStream alloc] initWithURL:[NSURL URLWithString:@"http://10.0.0.200:55000"] append:NO];
    
//    CFReadStreamRef readStream;
//    CFWriteStreamRef writeStream;
//    
//    
//    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)WWW_HOST, WWW_PORT, &readStream, &writeStream);
//    
//    InputStream = (__bridge NSInputStream *)readStream;
//    OutputStream = (__bridge NSOutputStream *)writeStream;
//    
    [InputStream setDelegate:self];
    [OutputStream setDelegate:self];
    
    [InputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [OutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [InputStream open];
    [OutputStream open];
}



//****************************************
//****************************************
//********** TCP CLIENT RECEIVE **********
//****************************************
//****************************************
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)StreamEvent
{
    
    switch (StreamEvent)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"TCP Client - Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == InputStream)
            {
                uint8_t buffer[1024];
                NSInteger len;
                
                while ([InputStream hasBytesAvailable])
                {
                    len = [InputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output)
                        {
                            NSLog(@"TCP Client - Server sent: %@", output);
                        }
                        
                        
                        
                        //Send some data (large block where the write may not actually send all we request it to send)
                        NSInteger ActualOutputBytes = [OutputStream write:[OutputData bytes] maxLength:[OutputData length]];
                        NSInteger ChunkToSendLength = [OutputData length];
                        if (ActualOutputBytes >= ChunkToSendLength)
                        {
                            //It was all sent
                            //[OutputData release];
                            OutputData = nil;
                        }
                        else
                        {
                            //Only partially sent
                            [OutputData replaceBytesInRange:NSMakeRange(0, ActualOutputBytes) withBytes:NULL length:0];		//Remove sent bytes from the start
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"TCP Client - Can't connect to the host");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"TCP Client - End encountered");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        case NSStreamEventNone:
            NSLog(@"TCP Client - None event");
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"TCP Client - Has space available event");
            if (OutputData != nil)
            {
                //Send rest of the packet
                NSInteger ActualOutputBytes = [OutputStream write:[OutputData bytes] maxLength:[OutputData length]];
                
                if (ActualOutputBytes >= [OutputData length])
                {
                    //It was all sent
                    //[OutputData release];
                    OutputData = nil;
                }
                else
                {
                    //Only partially sent
                    [OutputData replaceBytesInRange:NSMakeRange(0, ActualOutputBytes) withBytes:NULL length:0];		//Remove sent bytes from the start
                }
            }
            break;
            
        default:
            NSLog(@"TCP Client - Unknown event");
    }
    
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setup];
        DLogFunctionLine();
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
    DLogFunctionLine();
}

- (void)setup {
    __weak TodayViewController *weakSelf = self;
    
    self.powerStateAction = 0;
    self.powerStateRetry = 0;
    
    // Allocate a reachability object
//    if (!self.reach) {
//        self.reach = [Reachability reachabilityWithHostname:@"10.0.0.200"];
//        
//        // Set the blocks
//        self.reach.reachableBlock = ^(Reachability*reach)
//        {
//            NSString *bssid = [[PayloadData fetchSSIDInfo] objectForKey:@"BSSID"];
//            
//            // keep in mind this is called on a background thread
//            // and if you are updating the UI it needs to happen
//            // on the main thread, like this:
//            //if ([reach isReachableViaWiFi] && [bssid isEqualToString:@"80:ea:96:ef:20:2"]) {
//                //[weakSelf startSocket];
//            if (weakSelf.powerStateAction == -1) {
//                [weakSelf startSocket];
//            }
//        
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    //[weakSelf.view showConnecting];
//                    NSLog(@"REACHABLE!");
//                });
//            //}
//        };
//        
//        self.reach.unreachableBlock = ^(Reachability*reach)
//        {
//            NSLog(@"UNREACHABLE!");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.view showPoweredOff];
//                //[weakSelf.view showUnreachable];
//            });
//        };
//        
//        // Start the notifier, which will cause the reachability object to retain itself!
//        [self.reach startNotifier];
//    }
//    if (!self.castReach) {
//        self.castReach = [Reachability reachabilityWithHostname:@"Living Room.local"];
//        
//        // Set the blocks
//        self.castReach.reachableBlock = ^(Reachability*reach)
//        {
//            NSString *bssid = [[PayloadData fetchSSIDInfo] objectForKey:@"BSSID"];
//            
//            // keep in mind this is called on a background thread
//            // and if you are updating the UI it needs to happen
//            // on the main thread, like this:
//            if ([reach isReachableViaWiFi] && [bssid isEqualToString:@"80:ea:96:ef:20:2"]) {
//                //[weakSelf startSocket];
//                
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    //[weakSelf.view showConnecting];
//                    //NSLog(@"REACHABLE!");
//                });
//            }
//        };
//        
//        self.castReach.unreachableBlock = ^(Reachability*reach)
//        {
//            NSLog(@"UNREACHABLE!");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.view showUnreachable];
//            });
//        };
//        
//        // Start the notifier, which will cause the reachability object to retain itself!
//        [self.castReach startNotifier];
//    }
    
    //if (!self.manager) {
        //self.manager = [AFHTTPRequestOperationManager manager];
        //self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //[[AFHTTPRequestOperationManager manager].requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //}
    //if (!self.connected && !self.connectionAttempt {
        //[self TcpClientInitialise];
        [self startSocket];
        //DLogObject([PayloadData fetchSSIDInfo]);
    //}
}

- (CGSize)preferredContentSize {
    DLogFunctionLine();
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 90);
    //return CGSizeMake([UIScreen mainScreen].bounds.size.width, 1024);
}


//
- (void)loadView {
    DLogFunctionLine();
    self.view = [[TodayView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
}

//- (void)updateViewConstraints {
//    //CGFloat height = MAX(200.0f, 36.0f * selectedFacets.count);
////    NSLayoutConstraint *wc = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NSLayoutAttributeW attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0];
////    [self.view addConstraint:wc];
//    //[self.view removeConstraints:self.view.constraints];
//    CGFloat height = 56;
//    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:height];
//    [self.view addConstraint:lc];
//    self.heightConstraint = lc;
//    [super updateViewConstraints];
//}
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    DLogFunctionLine();
    self.view.delegate = self;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self setup];
    
    
    
    
//    self.userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.pasteboard"];
//    
//    self.data = @[@"Living Room TV"];
    
//    self.pasteboard.layer.shouldRasterize = YES;
//    self.pasteboard.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    //self.pasteboard.layer.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3].CGColor;
//    //self.pasteboard.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
//    //self.pasteboard.layer.borderWidth = 0;
//    self.pasteboard.layer.cornerRadius = 10;
//    self.pasteboard.clipsToBounds = YES;
//    
//    self.pasteNormalColor = self.pasteboard.backgroundColor;
//    self.pasteHighlightColor = [UIColor colorWithWhite:1.0 alpha:0.1];
//    
//    self.pasteboardText.layer.shouldRasterize = YES;
//    self.pasteboardText.layer.rasterizationScale = [UIScreen mainScreen].scale;
//
//    self.pasteGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pasteGesture:)];
//    self.pasteGestureRecognizer.minimumPressDuration = 0.01;
//    self.pasteGestureRecognizer.numberOfTapsRequired = 0;
//    [self.pasteboard addGestureRecognizer:self.pasteGestureRecognizer];
    
//    NSArray *pasteboard = [self.userDefaults objectForKey:@"apppasteboard"];
//    NSMutableArray *array;
//    if (pasteboard) {
//        self.data = [NSMutableArray arrayWithArray:array];
//    } else {
//        self.data = [NSMutableArray arrayWithCapacity:5];
//    }
//    NSLog(@"%@", [[UIPasteboard generalPasteboard] strings]);
//    [[UIPasteboard generalPasteboard] setPersistent:YES];
//    
    //self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 4 + 44 + 4 + 44);
    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.3];
//    self.tableView.separatorInset = UIEdgeInsetsZero;
//    
//    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:TableViewCellIdentifier];
//
//    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 500)];
//    blackView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:blackView];
    //[self.view setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    DLogFunctionLine();
    DLogCGRect(self.view.frame);
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    self.connectionAttempt = NO;
    self.powerStateAction = 0;
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLogFunctionLine();
    [self setup];
    DLogCGRect(self.view.frame);
    BOOL canConnect = [TodayViewController canConnect];
    DLogBOOL(canConnect);
    NSParameterAssert(canConnect);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.asyncSocket disconnect];
    self.asyncSocket.delegate = nil;
    self.asyncSocket = nil;
    DLogFunctionLine();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    __weak TodayViewController *weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        TodayViewController *strongSelf = weakSelf;
//        //[strongSelf.asyncSocket disconnect];
//        //strongSelf.asyncSocket = nil;
//        [InputStream close];
//        [OutputStream close];
//        InputStream = nil;
//        OutputStream = nil;
//    });
    //[self.view showConnecting];
    DLogFunctionLine();
}

#pragma mark - 
#pragma mark Gesture Recognizer Methods


- (void)pastePasteboard {
//    self.pasteboard.backgroundColor = self.pasteNormalColor;
//    
//    //NSArray *items = [[UIPasteboard generalPasteboard] items];
//    
//    
//    NSString *string = [[UIPasteboard generalPasteboard] string];
//    
//    
//    
//    if (self.data.count > 0) {
//        if (![string isEqualToString:self.data[0]]) {
//            [self.data addObject:string];
//        } else {
//            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
//        }
//    } else {
//        [self.data addObject:string];
//    }
//    
//    [self.userDefaults setObject:[NSArray arrayWithArray:self.data] forKey:@"apppasteboard"];
//    [self.userDefaults synchronize];
//    
//    [UIView performWithoutAnimation:^{
//        self.contentHeightConstraint.constant = (self.data.count + 1) * 44.0;
//        [self.tableView reloadData];
//    }];
    //self.pasteboardText.text = [[UIPasteboard generalPasteboard] string];
    
}

- (void)pasteGesture:(UILongPressGestureRecognizer*)gc {
    switch (gc.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            self.pasteboard.backgroundColor = self.pasteHighlightColor;
            break;
        case UIGestureRecognizerStateCancelled:
            self.pasteboard.backgroundColor = self.pasteNormalColor;
            break;
        case UIGestureRecognizerStateFailed:
            self.pasteboard.backgroundColor = self.pasteNormalColor;
            break;
        case UIGestureRecognizerStateRecognized:
            [self pastePasteboard];
            break;
        case UIGestureRecognizerStateChanged:
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}


#pragma mark -
#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier forIndexPath:indexPath];
//    
//    if (!cell) {
//        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
//        
//    }
    
    cell.textLabel.text = self.data[0];
    cell.detailTextLabel.text = @"Power Off";
    
//    UILongPressGestureRecognizer *powerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(powerGesture:)];
//    powerGesture.minimumPressDuration = 0.01;
//    powerGesture.numberOfTapsRequired = 0;
//    [cell.volumeUp addGestureRecognizer:powerGesture];
//    
//    if (indexPath.row < 1) {
//        cell.textLabel.text = @"";
//    } else {
//        [UIView performWithoutAnimation:^{
//            cell.textLabel.text = [self.data objectAtIndex:indexPath.row-1];
//            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
//            [cell updateConstraintsIfNeeded];
//        }];
//    }
    return cell;
}
//

//- (IBAction)searchForSite:(id)sender
//{
//    NSString *urlStr = @"10.0.0.200";
//    if (![urlStr isEqualToString:@""]) {
//        NSURL *website = [NSURL URLWithString:urlStr];
//        if (!website) {
//            NSLog(@"%@ is not a valid URL", urlStr);
//            return;
//        }
//        
//        CFReadStreamRef readStream;
//        CFWriteStreamRef writeStream;
//        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)urlStr, 55000, &readStream, &writeStream);
//        
//        NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
//        NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
//        [inputStream setDelegate:self];
//        [outputStream setDelegate:self];
//        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        [inputStream open];
//        [outputStream open];
//        
//        self.inputStream = inputStream;
//        self.outputStream = outputStream;
//        
//        /* Store a reference to the input and output streams so that
//         they don't go away.... */
//    }
//}
//
//- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
//    NSLog(@"stream:handleEvent: is invoked...");
//    
//    switch(eventCode) {
//        case NSStreamEventHasSpaceAvailable:
//        {
//            if (stream == oStream) {
//                NSString * str = [NSString stringWithFormat:
//                                  @"GET / HTTP/1.0\r\n\r\n"];
//                const uint8_t * rawstring =
//                (const uint8_t *)[str UTF8String];
//                [oStream write:rawstring maxLength:strlen(rawstring)];
//                [oStream close];
//            }
//            break;
//        }
//        case NSStreamEventNone {
//            
//            break;
//        }
//        case NSStreamEventEndEncountered: {
//        
//            break;
//        }
//        case NSStreamEventErrorOccurred: {
//            break;
//        }
//        case NSStreamEventHasBytesAvailable: {
//            break;
//        }
//            // continued ...
//    }
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell performSelector:@selector(startSocket)];
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"chunk" ofType:@"js"];
//    if (filePath) {
//        NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//        if (myText) {
////            textView.text= myText;
//            
//            JSContext *context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
//            //context[@"a"] = @5;
//            
//            JSValue *retValue = [context evaluateScript:myText];
//            NSLog(@"ret: %@", [retValue toString]);
//            JSValue *chunkOne = context[@"chunkOne"];
//            JSValue *chunkTwo = context[@"chunkTwo"];
//            NSLog(@"1: %@", [chunkOne toString]);
//            NSLog(@"2: %@", [chunkTwo toString]);
//        }
//    }
//    
//    //NSLog(@"%@");
    
   //[self startSocket];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (void)volumeUpAction {
    if (self.connected) {
        NSData *chunkOne = [PayloadData chunkOne];
        NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandVolumeUp];
        //[self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
        //[self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    }
}

- (void)volumeDownAction {
    //if (self.connected) {
        NSData *chunkOne = [PayloadData chunkOne];
        NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandVolumeDown];
        //[self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
        //[self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    //}
}

- (void)volumeMuteAction {
    //if (self.connected) {
        NSData *chunkOne = [PayloadData chunkOne];
        NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandVolumeMute];
        //[self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
        //[self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    //}
}

- (void)powerOnAction {
    [self powerOnCommand];
}

- (void)powerOffAction {
    //if (self.connected) {
        [self powerOffCommand];
    //} else {
    //    [self setup];
    //}
}


- (void)powerAction {
    //[self setup];
    if (self.connected) {
        [self powerOffCommand];
    } else {
        [self powerOnCommand];
    }
//    if (self.connected) {
//        NSData *chunkOne = [PayloadData chunkOne];
//        NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandPowerOff];
//        [self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
//        [self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
//    } else {
//        // shit is going down....
//        
//    }
    //NSDictionary *data =
    //NSURL *url = [NSURL URLWithString:@"http://Living Room.local:8008/apps/YouTube"];
    //[self powerOnCommand];
    
}


- (void)resolveURL {
    Boolean result;
    NSArray *addresses;
    NSString *hostname = @"livingroom.local";
    CFStreamError error;
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
    if (hostRef) {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, &error); // pass an error instead of NULL here to find out why it failed
        if (result == TRUE) {
            addresses = (__bridge NSArray*)CFHostGetAddressing(hostRef, &result);
        }
    }
    if (result == TRUE) {
        NSMutableArray *tempDNS = [[NSMutableArray alloc] init];
        for(int i = 0; i < CFArrayGetCount((__bridge CFArrayRef)addresses); i++){
            struct sockaddr_in* remoteAddr;
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex((__bridge CFArrayRef)addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
            
            if(remoteAddr != NULL){
                // Extract the ip address
                //const char *strIP41 = inet_ntoa(remoteAddr->sin_addr);
                NSString *strDNS =[NSString stringWithCString:inet_ntoa(remoteAddr->sin_addr) encoding:NSASCIIStringEncoding];
                NSLog(@"RESOLVED %d:<%@>", i, strDNS);
                [tempDNS addObject:strDNS];
            }
        }
    }
}

- (void)powerOffCommand {
    
    
    NSData *chunkOne = [PayloadData chunkOne];
    NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandPowerOff];
    
    
    //**********************************
    //**********************************
    //********** SENDING DATA **********
    //**********************************
    //**********************************
    //NSString *response  = @"HELLO1234";
    //NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    //[OutputStream write:[chunkOne bytes] maxLength:[chunkOne length]];	//<<Returns actual number of bytes sent - check if trying to send a large number of bytes as they may well not have all gone in this write and will need sending once there is a hasspaceavailable event
    //[OutputStream write:[chunkTwo bytes] maxLength:[chunkTwo length]];
    
    [self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
    [self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    [self.view showPoweredOff];
}

//- (NSString*)lookupHostIPAddressForURL:(NSURL*)url
//{
//    // Ask the unix subsytem to query the DNS
//    struct hostent *remoteHostEnt = gethostbyname([[url host] UTF8String]);
//    // Get address info from host entry
//    struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
//    // Convert numeric addr to ASCII string
//    char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
//    // hostIP
//    NSString* hostIP = [NSString stringWithUTF8String:sRemoteInAddr];
//    return hostIP;
//}

- (void)powerOnCommand {
    __weak TodayViewController *weakSelf = self;
    self.powerStateAction = -1;
    
    NSURL *URL = [NSURL URLWithString:@"http://10.0.0.16:8008/apps/YouTube"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:@"livingroom.local:8008" forHTTPHeaderField:@"Host"];
    [request addValue:@"8" forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request addValue:@"deflate, gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request addValue:@"curl/7.30.0" forHTTPHeaderField:@"User-Agent"];
    //const char data = "v=000000";
    //NSData *dataObj = [NSData dataWithBytes:&data length:sizeof(data)];
    [request setHTTPBody:[@"v=000000" dataUsingEncoding:NSASCIIStringEncoding]];
    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        DLogObject(response);
//        DLogObject(data);
//        DLogObject(connectionError);
//    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [weakSelf startSocket];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLogObject(error);
    }];
    [operation start];
    DLogObject([TTTURLRequestFormatter cURLCommandFromURLRequest:request]);
    
//    [[JSONHTTPRequestOperationManager manager] POST:@"http://LivingRoom.local:8008/apps/YouTube" parameters:@{@"v":@"0"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLogObject(operation);
//        DLogObject(responseObject);
//        [weakSelf startSocket];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DLogObject(error);
//        DLogObject(operation);
//    }];
}

- (void)inputHDMISource {
    //if (self.connected) {
    
    NSData *chunkOne = [PayloadData chunkOne];
    NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandHDMISource];
    //[self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
    //[self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    //}
}

- (void)input1Action {
    //if (self.connected) {
        
        NSData *chunkOne = [PayloadData chunkOne];
        NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandInputOne];
        //[self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
        //[self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    //}
}

- (void)input2Action {
    //if (self.connected) {
        
        NSData *chunkOne = [PayloadData chunkOne];
        NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandInputTwo];
        //[self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
        //[self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    //}
}

- (void)input3Action {
    if (self.connected) {
        
        NSData *chunkOne = [PayloadData chunkOne];
        NSData *chunkTwo = [PayloadData chunkTwoWithCommand:PayloadDataKeyCommandInputThree];
        //[self.asyncSocket writeData:chunkOne withTimeout:-1.0 tag:0];
        //[self.asyncSocket writeData:chunkTwo withTimeout:-1.0 tag:0];
    }
}

#pragma mark - 
#pragma mark - GCDAsyncSocket


- (void)startSocket
{
    // Create our GCDAsyncSocket instance.
    //
    // Notice that we give it the normal delegate AND a delegate queue.
    // The socket will do all of its operations in a background queue,
    // and you can tell it which thread/queue to invoke your delegate on.
    // In this case, we're just saying invoke us on the main thread.
    // But you can see how trivial it would be to create your own queue,
    // and parallelize your networking processing code by having your
    // delegate methods invoked and run on background queues.
    
    GCDAsyncSocket *asyncSocket;
    if (!self.asyncSocket) {
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        asyncSocket = self.asyncSocket;
    }
        // Now we tell the ASYNCHRONOUS socket to connect.
    //
    // Recall that GCDAsyncSocket is ... asynchronous.
    // This means when you tell the socket to connect, it will do so ... asynchronously.
    // After all, do you want your main thread to block on a slow network connection?
    //
    // So what's with the BOOL return value, and error pointer?
    // These are for early detection of obvious problems, such as:
    //
    // - The socket is already connected.
    // - You passed in an invalid parameter.
    // - The socket isn't configured properly.
    //
    // The error message might be something like "Attempting to connect without a delegate. Set a delegate first."
    //
    // When the asynchronous sockets connects, it will invoke the socket:didConnectToHost:port: delegate method.
    
    NSError *error = nil;
    
    uint16_t port = WWW_PORT;
    if (port == 0)
    {
#if USE_SECURE_CONNECTION
        port = 443; // HTTPS
#else
        port = 80;  // HTTP
#endif
    }
    
    if (![asyncSocket connectToHost:WWW_HOST onPort:port withTimeout:-1 error:&error])
    {
        [self.view showError];
        NSLog(@"Unable to connect to due to invalid configuration: %@", error);
    }
    else
    {
        
        //[self.view showConnecting];
        NSLog(@"Connecting to \"%@\" on port %hu...", WWW_HOST, port);
    }
    
#if USE_SECURE_CONNECTION
    
    // The connect method above is asynchronous.
    // At this point, the connection has been initiated, but hasn't completed.
    // When the connection is established, our socket:didConnectToHost:port: delegate method will be invoked.
    //
    // Now, for a secure connection we have to connect to the HTTPS server running on port 443.
    // The SSL/TLS protocol runs atop TCP, so after the connection is established we want to start the TLS handshake.
    //
    // We already know this is what we want to do.
    // Wouldn't it be convenient if we could tell the socket to queue the security upgrade now instead of waiting?
    // Well in fact you can! This is part of the queued architecture of AsyncSocket.
    //
    // After the connection has been established, AsyncSocket will look in its queue for the next task.
    // There it will find, dequeue and execute our request to start the TLS security protocol.
    //
    // The options passed to the startTLS method are fully documented in the GCDAsyncSocket header file.
    
#if USE_CFSTREAM_FOR_TLS
    {
        // Use old-school CFStream style technique
        
        NSDictionary *options = @{
                                  GCDAsyncSocketUseCFStreamForTLS : @(YES),
                                  GCDAsyncSocketSSLPeerName : CERT_HOST
                                  };
        
        DDLogVerbose(@"Requesting StartTLS with options:\n%@", options);
        [asyncSocket startTLS:options];
    }
#elif MANUALLY_EVALUATE_TRUST
    {
        // Use socket:didReceiveTrust:completionHandler: delegate method for manual trust evaluation
        
        NSDictionary *options = @{
                                  GCDAsyncSocketManuallyEvaluateTrust : @(YES),
                                  GCDAsyncSocketSSLPeerName : CERT_HOST
                                  };
        
        DDLogVerbose(@"Requesting StartTLS with options:\n%@", options);
        [asyncSocket startTLS:options];
    }
#else
    {
        // Use default trust evaluation, and provide basic security parameters
        
        NSDictionary *options = @{
                                  GCDAsyncSocketSSLPeerName : CERT_HOST
                                  };
        
        DDLogVerbose(@"Requesting StartTLS with options:\n%@", options);
        [asyncSocket startTLS:options];
    }
#endif
    
#endif
}




- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:didConnectToHost:%@ port:%hu", host, port);
    
    // HTTP is a really simple protocol.
    //
    // If you don't already know all about it, this is one of the best resources I know (short and sweet):
    // http://www.jmarshall.com/easy/http/
    //
    // We're just going to tell the server to send us the metadata (essentially) about a particular resource.
    // The server will send an http response, and then immediately close the connection.
    
    self.connected = YES;
    [self.view showConnected];
    DLogFunctionLine();
    if (self.powerStateAction == -1) {
        [self inputHDMISource];
        DLogObject(@"CHANGING HDMI INPUT BY 1");
        self.powerStateAction = 0;
        //self.powerStateRetry = -1;
    }
    //NSString *requestStrFrmt = @"HEAD / HTTP/1.0\r\nHost: %@\r\n\r\n";
    
    //NSString *requestStr = [NSString stringWithFormat:requestStrFrmt, WWW_HOST];
    //NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
   
    //NSLog(@"Sending HTTP Request:", self.asyncSocket);
    
    // Side Note:
    //
    // The AsyncSocket family supports queued reads and writes.
    //
    // This means that you don't have to wait for the socket to connect before issuing your read or write commands.
    // If you do so before the socket is connected, it will simply queue the requests,
    // and process them after the socket is connected.
    // Also, you can issue multiple write commands (or read commands) at a time.
    // You don't have to wait for one write operation to complete before sending another write command.
    //
    // The whole point is to make YOUR code easier to write, easier to read, and easier to maintain.
    // Do networking stuff when it is easiest for you, or when it makes the most sense for you.
    // AsyncSocket adapts to your schedule, not the other way around.
    
#if READ_HEADER_LINE_BY_LINE
    
    // Now we tell the socket to read the first line of the http response header.
    // As per the http protocol, we know each header line is terminated with a CRLF (carriage return, line feed).
    
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
    
#else
    
    // Now we tell the socket to read the full header for the http response.
    // As per the http protocol, we know the header is terminated with two CRLF's (carriage return, line feed).
    
    NSData *responseTerminatorData = [@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    
    [self.asyncSocket readDataToData:responseTerminatorData withTimeout:-1.0 tag:0];
    
#endif
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    //NSLog(@"socket:shouldTrustPeer:");
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        // This is where you would (eventually) invoke SecTrustEvaluate.
        // Presumably, if you're using manual trust evaluation, you're likely doing extra stuff here.
        // For example, allowing a specific self-signed certificate that is known to the app.
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    // This method will be called if USE_SECURE_CONNECTION is set
    
    NSLog(@"socketDidSecure:");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:didWriteDataWithTag:");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket:didReadData:withTag:");
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
#if READ_HEADER_LINE_BY_LINE
    
    DDLogInfo(@"Line httpResponse: %@", httpResponse);
    
    // As per the http protocol, we know the header is terminated with two CRLF's.
    // In other words, an empty line.
    
    if ([data length] == 2) // 2 bytes = CRLF
    {
        DDLogInfo(@"<done>");
    }
    else
    {
        // Read the next line of the header
        [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
    }
    
#else
    
    NSLog(@"Full HTTP Response:\n%@", httpResponse);
    
#endif
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    // Since we requested HTTP/1.0, we expect the server to close the connection as soon as it has sent the response.
    
    NSLog(@"socketDidDisconnect:withError: \"%@\"", err);
    self.connected = NO;
    self.connectionAttempt = YES;
    self.powerStateAction = 0;
    [self.view showError];
    //[self.view showConnecting];
    
//    if (err.code == 3) {
//        // timed out... lets just start over
//        if (self.powerStateRetry < 15 && self.powerStateRetry > -1) {
//            [self startSocket];
//            self.powerStateRetry = self.powerStateRetry+1;
//        }
//    }
//    if (self.view.superview) {
//        [self setup];
//    }
}

@end
