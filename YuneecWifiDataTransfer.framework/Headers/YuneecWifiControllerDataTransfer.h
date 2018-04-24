//
//  YuneecWifiControllerDataTransfer.h
//  YuneecWifiDataTransfer
//
//  Created by tbago on 2017/9/18.
//  Copyright © 2017年 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecWifiControllerDataTransfer;

@protocol YuneecWifiCameraControllerDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive camera data
 *
 * @param dataTransfer YuneecWifiControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)wifiControllerDataTransfer:(YuneecWifiControllerDataTransfer *) dataTransfer
              didReceiveCameraData:(NSData *) data;

@end

@protocol YuneecWifiFlyingControllerDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive flying controller data
 *
 * @param dataTransfer YuneecWifiControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)wifiControllerDataTransfer:(YuneecWifiControllerDataTransfer *) dataTransfer
    didReceiveFlyingControllerData:(NSData *) data;

@end


@protocol YuneecWifiUpgradeStateDataTransferDelegate <NSObject>

@required

/**
 * call this delegate when receive upgrade state data
 *
 * @param dataTransfer YuneecWifiControllerDataTransfer instance
 * @param data mavlink_message_t struct bytes
 */
- (void)wifiControllerDataTransfer:(YuneecWifiControllerDataTransfer *) dataTransfer
        didReceiveUpgradeStateData:(NSData *) data;

@end

@interface YuneecWifiControllerDataTransfer : NSObject

/*
 * Use this delegate for receive camera controller data.
 */
@property (nonatomic, weak, nullable) id<YuneecWifiCameraControllerDataTransferDelegate>   cameraControllerDelegate;

/*
 * Use this delegate for receive flying controller data.
 */
@property (nonatomic, weak, nullable) id<YuneecWifiFlyingControllerDataTransferDelegate>   flyingControllerDelegate;

/**
 * Use this delegate for receive upgrade state data.
 */
@property (nonatomic, weak, nullable) id<YuneecWifiUpgradeStateDataTransferDelegate>       upgradeStateDelegate;

/**
 * send data
 * may need queue send data
 * @param data the data to send
 */
- (void)sendData:(NSData *) data;

/**
 * close
 * close udp socket
 */
- (void)close;

@end

NS_ASSUME_NONNULL_END
