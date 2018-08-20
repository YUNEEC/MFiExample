//
//  YuneecConnectionStateAdapter.m
//  YuneecPreviewDemo
//
//  Created by tbago on 07/02/2018.
//  Copyright © 2018 yuneec. All rights reserved.
//

#import "YuneecConnectionStateAdapter.h"

#import <UIKit/UIKit.h>
#import <BaseFramework/DeviceUtility.h>

#import <YuneecDataTransferManager/YuneecDataTransferConnectionState.h>
#import <YuneecDataTransferManager/YuneecDataTransferManager.h>

NSString * const kConnectionStateNotification  = @"kConnectionStateNotification";

@interface YuneecConnectionStateAdapter() <YuneecDataTransferConnectionStateDelegate>

@property (assign, nonatomic, readwrite) BOOL                       connected;
@property (assign, nonatomic) YuneecDataTransferConnectionType      connectionType;
@property (strong, nonatomic) YuneecDataTransferConnectionState     *connectionState;

@end

@implementation YuneecConnectionStateAdapter

#pragma mark - init

+ (instancetype)sharedInstance {
    static YuneecConnectionStateAdapter *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[self alloc] init];
    });
    return sInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)applicationDidEnterBackground {
    [self.connectionState stopMonitorConnectionState];
}

- (void)applicationWillEnterForeground {
    [self.connectionState startMonitorConnectionState];
}

#pragma mark - public method

- (void)startMonitorConnectionState {
    [self.connectionState startMonitorConnectionState];
}

#pragma mark - YuneecDataTransferConnectionStateDelegate

- (void)connectionState:(YuneecDataTransferConnectionState *) connectionState
   changeConnectionType:(YuneecDataTransferConnectionType) connectionType
               fromType:(YuneecDataTransferConnectionType) fromType
{
    if (fromType == YuneecDataTransferConnectionTypeWifi && connectionType == YuneecDataTransferConnectionTypeMFi) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"Change to MFi connection"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }

    self.connectionType = connectionType;
    if (self.connectionType == YuneecDataTransferConnectionTypeNone) {
        self.connected = NO;
        NSLog(@"No connection");
    }
    else if (self.connectionType == YuneecDataTransferConnectionTypeWifi) {
        self.connected = YES;
        NSLog(@"Wi-Fi connected:%@", getCurrentWifiSSID());
    }
    else if (self.connectionType == YuneecDataTransferConnectionTypeMFi) {
        self.connected = YES;
        NSLog(@"Connected with remote controller");
    }

    [[YuneecDataTransferManager sharedInstance] setCurrentDataTransferType:connectionType];

    NSDictionary* userInfo = @{@"OBConnectionState": @(self.connected),
                               @"OBConnectionType": @(connectionType)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionStateNotification object:nil userInfo:userInfo];

}

#pragma mark - get & set

- (YuneecDataTransferConnectionState *)connectionState {
    if (_connectionState == nil) {
        _connectionState = [[YuneecDataTransferConnectionState alloc] init];
        _connectionState.connectionDelegate = self;
    }
    return _connectionState;
}
@end
