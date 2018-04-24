//
//  YuneecMFiUpgradeDataTransfer.h
//  YuneecMFiDataTransfer
//
//  Created by tbago on 16/03/2018.
//  Copyright © 2018 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecMFiUpgradeDataTransfer;

@protocol YuneecMFiUpgradeDataTransferDelegate <NSObject>

@required

- (void)MFiUpgradeDataTransferDidSendData;

- (void)MFiUpgradeDataTransfer:(YuneecMFiUpgradeDataTransfer *) dataTransfer
                didReceiveData:(NSData *) data;

@end

@interface YuneecMFiUpgradeDataTransfer : NSObject

@property (nonatomic, weak, nullable) id<YuneecMFiUpgradeDataTransferDelegate>    delegate;

- (BOOL)connectToServer;

- (void)disconnectToServer;

- (void)sendData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
