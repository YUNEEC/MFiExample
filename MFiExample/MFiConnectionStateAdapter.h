//
//  OBConnectionStateAdapter.h
//  OBClient
//
//  Created by tbago on 2017/9/8.
//  Copyright © 2017年 yuneec. All rights reserved.
//
#import <Foundation/Foundation.h>

extern NSString * const kMFiConnectionStateNotification;

@interface MFiConnectionStateAdapter : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitorConnectionState;
- (void)stopMonitorConnectionState ;
- (BOOL)getMFiConnectionState;
- (NSDictionary *)getConnectionStatus;

@property (nonatomic, assign, readonly) BOOL connected;
@property (nonatomic, assign, readonly) BOOL bDroneMonitorLost;
@end
