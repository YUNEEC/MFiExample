//
//  YuneecControllerDataTransfer.h
//  YuneecDataTransferManager
//
//  Created by tbago on 16/11/2017.
//  Copyright © 2017 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecControllerDataTransfer;

@protocol YuneecCameraControllerDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive camera data
 *
 * @param dataTransfer YuneecControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)controllerDataTransfer:(YuneecControllerDataTransfer *) dataTransfer
          didReceiveCameraData:(NSData *) data;

@end

@protocol YuneecFlyingControllerDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive flying controller data
 *
 * @param dataTransfer YuneecControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)controllerDataTransfer:(YuneecControllerDataTransfer *) dataTransfer
didReceiveFlyingControllerData:(NSData *) data;

@end

@protocol YuneecUpgradeStateDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive upgrade state data
 *
 * @param dataTransfer YuneecControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)controllerDataTransfer:(YuneecControllerDataTransfer *) dataTransfer
    didReceiveUpgradeStateData:(NSData *) data;

@end

@interface YuneecControllerDataTransfer : NSObject

/*
 * Use this delegate for receive camera controller data.
 */
@property (nonatomic, weak, nullable) id<YuneecCameraControllerDataTransferDelegate>   cameraControllerDelegate;

/*
 * Use this delegate for receive flying controller data.
 */
@property (nonatomic, weak, nullable) id<YuneecFlyingControllerDataTransferDelegate>   flyingControllerDelegate;

/**
 * Use this delegate for receive upgrade state data.
 */
@property (nonatomic, weak, nullable) id<YuneecUpgradeStateDataTransferDelegate>        upgradeStateDelegate;

/**
 * send data
 * may need queue send data
 * @param data the data to send
 */
- (void)sendData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
