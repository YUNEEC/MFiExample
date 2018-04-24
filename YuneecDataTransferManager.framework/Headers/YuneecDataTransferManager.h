//
//  YuneecDataTransferManager.h
//  YuneecDataTransferManager
//
//  Created by tbago on 16/11/2017.
//  Copyright © 2017 yuneec. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <YuneecDataTransferManager/YuneecDataTransferConnectionState.h>
#import <YuneecDataTransferManager/YuneecCameraStreamDataTransfer.h>
#import <YuneecDataTransferManager/YuneecControllerDataTransfer.h>
#import <YuneecDataTransferManager/YuneecRemoteControllerDataTransfer.h>
#import <YuneecDataTransferManager/YuneecUpgradeDataTransfer.h>
#import <YuneecDataTransferManager/YuneecPhotoDownloadDataTransfer.h>

/**
 * manager for all data transfer
 */
@interface YuneecDataTransferManager: NSObject

+ (instancetype)sharedInstance;

- (void)setCurrentDataTransferType:(YuneecDataTransferConnectionType) transferType;

- (void)setStreamDataTransferType:(YuneecDataTransferConnectionType) transferType;

- (YuneecCameraStreamDataTransfer *)streamDataTransfer;

- (YuneecControllerDataTransfer *)controllerDataTransfer;

- (YuneecRemoteControllerDataTransfer *)remoteControllerDataTranfer;

- (YuneecUpgradeDataTransfer *)upgradeDataTransfer;

- (YuneecPhotoDownloadDataTransfer *)photoDownloadDataTransfer;

@end
