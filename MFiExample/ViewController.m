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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mfiStatus.text = @"View loaded";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleConnectionStateNotification:)
                                                 name:kMFiConnectionStateNotification
                                               object:nil];

    // TODO: connect MFi
    
    // TODO: subscribe to mavlink
    
    // TODO: printf mavlink
    
    // TODO: forward mavlink via UDP on localhost
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleConnectionStateNotification:(NSNotification*) notification {
    NSDictionary *userInfo = notification.userInfo;
    BOOL connected = [userInfo[@"MFiConnectionState"] boolValue];
    YuneecDataTransferConnectionType connectionType = [userInfo[@"MFiConnectionType"] integerValue];
    
    if (connected) {
        if (connectionType == YuneecDataTransferConnectionTypeWifi) {
            NSLog(@"Wifi connected");
        }
        else {
            // No need to loop send data for MFi connection
            NSLog(@"MFi connected");
        }
    }
    else {
        NSLog(@"Nothing connected");
    }
}


@end
