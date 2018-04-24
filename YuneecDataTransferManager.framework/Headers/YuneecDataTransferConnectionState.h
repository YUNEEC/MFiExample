//
//  YuneecDataTransferConnectionState.h
//  YuneecDataTransferManager
//
//  Created by tbago on 16/11/2017.
//  Copyright © 2017 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecDataTransferConnectionState;

typedef NS_ENUM (NSUInteger, YuneecDataTransferConnectionType) {
    YuneecDataTransferConnectionTypeMFi,
    YuneecDataTransferConnectionTypeWifi,
    YuneecDataTransferConnectionTypeNone,
};


/**
 * connection state change logic
 * none -> MFi
 * MFi -> none
 * none -> Wifi
 * Wifi -> none
 * WiFi -> MFi (need user confirm)
 * MFi  -> Wifi (impossible)
 */
@protocol YuneecDataTransferConnectionStateDelegate <NSObject>

- (void)connectionState:(YuneecDataTransferConnectionState *) connectionState
   changeConnectionType:(YuneecDataTransferConnectionType) connectionType
               fromType:(YuneecDataTransferConnectionType) fromType;

@end

@interface YuneecDataTransferConnectionState : NSObject

/**
 * Use this delegate for connection status changed.
 */
@property (nonatomic, weak, nullable) id<YuneecDataTransferConnectionStateDelegate>   connectionDelegate;

/**
 * Start monitor connection state.
 */
- (void)startMonitorConnectionState;

/**
 * Stop monitor connection state.
 */
- (void)stopMonitorConnectionState;


/**
 * manual change connection type
 * only for user confirm state change (Wifi->MFi)
 *
 * @param connectionType input connectionType
 */
- (void)manualChangeConnectionType:(YuneecDataTransferConnectionType) connectionType;

/**
 * Get current connection type
 *
 * @return current connection type
 */
- (YuneecDataTransferConnectionType)getCurrentConnectionType;

@end

NS_ASSUME_NONNULL_END
