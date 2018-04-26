//
//  ViewController.m
//  MFiExample
//
//  Created by Julian Oes on 24.04.18.
//  Copyright © 2018 Yuneec. All rights reserved.
//

#import "ViewController.h"

#import "MFiConnectionStateAdapter.h"
#import <YuneecDataTransferManager/YuneecDataTransferConnectionState.h>


@interface ViewController ()

@property (assign, nonatomic) YuneecDataTransferConnectionType      connectionType;
@property (weak, nonatomic) IBOutlet UITextField *mfiStatus;
@property (weak, nonatomic) IBOutlet UITextView *mfiStatusFull;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mfiStatus.text = @"View loaded";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleConnectionStateNotification:)
                                                 name:kMFiConnectionStateNotification
                                               object:nil];

    [[MFiConnectionStateAdapter sharedInstance] startMonitorConnectionState];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self selector:@selector(checkConnection:) userInfo:nil repeats:YES];
    
    NSLog(@"done with creating adapter");
    
    // TODO: connect MFi
    
    // TODO: subscribe to mavlink
    
    // TODO: printf mavlink
    
    // TODO: forward mavlink via UDP on localhost
}

- (void) checkConnection:(NSTimer *)timer
{
    NSLog(@"Ran timer.");
    if ([[MFiConnectionStateAdapter sharedInstance] getMFiConnectionState]) {
        //self.mfiStatus.text = @"MFi connected much";
    } else {
        //self.mfiStatus.text = @"MFi not connected not so much";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleConnectionStateNotification:(NSNotification*) notification {
    NSDictionary *userInfo = notification.userInfo;
    BOOL connected = [userInfo[@"MFiConnectionState"] boolValue];
    YuneecDataTransferConnectionType connectionType = [userInfo[@"MFiConnectionType"] integerValue];
    
    [self.mfiStatusFull setText:[NSString stringWithFormat:@"%@", userInfo]];
    if (connected) {
        if (connectionType == YuneecDataTransferConnectionTypeWifi) {
            self.mfiStatus.text = @"Wifi connected";
        }
        else {
            // No need to loop send data for MFi connection
            self.mfiStatus.text = @"MFi connected";
        }
    }
    else {
        self.mfiStatus.text = @"Nothing connected";
    }
}


@end
