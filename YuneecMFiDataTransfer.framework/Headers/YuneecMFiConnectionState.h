//
//  YuneecMFiConnectionState.h
//  YuneecMFiDataTransfer
//
//  Created by tbago on 16/11/2017.
//  Copyright © 2017 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecMFiConnectionState;

@protocol YuneecMFiConnectionStateDelegate <NSObject>

@required
/*
 * Call when the data transfer connection state changed.
 */
- (void)MFiConnectionState:(YuneecMFiConnectionState *) MFiConnectionState connectionStateChanged:(BOOL) connected;

@end

@interface YuneecMFiConnectionState : NSObject

/*
 * Use this delegate for connection status changed.
 */
@property (nonatomic, weak, nullable) id<YuneecMFiConnectionStateDelegate>   connectionDelegate;

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
