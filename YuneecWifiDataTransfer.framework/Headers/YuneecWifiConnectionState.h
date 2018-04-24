//
//  YuneecWifiConnectionState.h
//  YuneecWifiDataTransfer
//
//  Created by tbago on 2017/9/6.
//  Copyright © 2017年 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecWifiConnectionState;

@protocol YuneecWifiConnectionStateDelegate <NSObject>

@required
/*
 * Call when the data transfer connection state changed.
 */
- (void)wifiConnectionState:(YuneecWifiConnectionState *) wifiConnectionState connectionStateChanged:(BOOL) connected;

@end

@interface YuneecWifiConnectionState : NSObject

/*
 * Use this delegate for connection status changed.
 */
@property (nonatomic, weak, nullable) id<YuneecWifiConnectionStateDelegate>   connectionDelegate;

/**
 * Start monitor connection state.
 */
- (void)startMonitorConnectionState;

/**
 * Stop monitor connection state.
 */
- (void)stopMonitorConnectionState;

@end

NS_ASSUME_NONNULL_END
