//
//  YuneecDataTransferUpgradeDataTransfer.h
//  YuneecDataTransferManager
//
//  Created by tbago on 16/03/2018.
//  Copyright © 2018 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecUpgradeDataTransfer;

@protocol YuneecUpgradeDataTransferDelegate <NSObject>

@required
/**
 * For asnyc send data success
 */
- (void)upgradeDataTransferDidSendData;

- (void)upgradeDataTransfer:(YuneecUpgradeDataTransfer *) dataTransfer
             didReceiveData:(NSData *) data;

@end

@interface YuneecUpgradeDataTransfer : NSObject

@property (nonatomic, weak, nullable) id<YuneecUpgradeDataTransferDelegate>    delegate;

- (BOOL)connectToServer;

- (void)disconnectToServer;

- (void)sendData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
