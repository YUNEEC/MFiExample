//
//  YuneecWifiUpgradeDataTransfer.h
//  YuneecWifiDataTransfer
//
//  Created by tbago on 16/03/2018.
//  Copyright © 2018 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecWifiUpgradeDataTransfer;

@protocol YuneecWifiUpgradeDataTransferDelegate <NSObject>

@required

- (void)wifiUpgradeDataTransferDidSendData;

- (void)wifiUpgradeDataTransfer:(YuneecWifiUpgradeDataTransfer *) dataTransfer
                 didReceiveData:(NSData *) data;

@end

@interface YuneecWifiUpgradeDataTransfer : NSObject

@property (nonatomic, weak, nullable) id<YuneecWifiUpgradeDataTransferDelegate>    delegate;

- (BOOL)connectToServer;

- (void)disconnectToServer;

- (void)sendData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
