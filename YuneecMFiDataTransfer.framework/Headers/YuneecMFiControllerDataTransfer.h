//
//  YuneecMFiControllerDataTransfer.h
//  YuneecMFiDataTransfer
//
//  Created by tbago on 17/11/2017.
//  Copyright © 2017 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecMFiControllerDataTransfer;

@protocol YuneecMFiCameraControllerDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive camera data
 *
 * @param dataTransfer YuneecMFiControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)MFiControllerDataTransfer:(YuneecMFiControllerDataTransfer *) dataTransfer
             didReceiveCameraData:(NSData *) data;

@end

@protocol YuneecMFiFlyingControllerDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive flying controller data
 *
 * @param dataTransfer YuneecMFiControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)MFiControllerDataTransfer:(YuneecMFiControllerDataTransfer *) dataTransfer
   didReceiveFlyingControllerData:(NSData *) data;

@end

@protocol YuneecMFiUpgradeStateDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive upgrade state data
 *
 * @param dataTransfer YuneecWifiControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)MFiControllerDataTransfer:(YuneecMFiControllerDataTransfer *) dataTransfer
       didReceiveUpgradeStateData:(NSData *) data;

@end

@interface YuneecMFiControllerDataTransfer : NSObject

/*
 * Use this delegate for receive camera controller data.
 */
@property (nonatomic, weak, nullable) id<YuneecMFiCameraControllerDataTransferDelegate>   cameraControllerDelegate;

/*
 * Use this delegate for receive flying controller data.
 */
@property (nonatomic, weak, nullable) id<YuneecMFiFlyingControllerDataTransferDelegate>   flyingControllerDelegate;

/**
 * Use this delegate for receive upgrade state data.
 */
@property (nonatomic, weak, nullable) id<YuneecMFiUpgradeStateDataTransferDelegate>         upgradeStateDelegate;

/**
 * send data
 * may need queue send data
 * @param data the data to send
 */
- (void)sendData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
