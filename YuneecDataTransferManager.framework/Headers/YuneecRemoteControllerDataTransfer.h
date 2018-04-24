//
//  YuneecRemoteControllerDataTransfer.h
//  YuneecDataTransferManager
//
//  Created by tbago on 27/11/2017.
//  Copyright © 2017 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecRemoteControllerDataTransfer;

@protocol YuneecRemoteControllerDataTransferDelegate <NSObject>

@required
- (void)remoteControllerDataTranfer:(YuneecRemoteControllerDataTransfer *) dataTransfer
                     didReceiveData:(NSData *) data;

@end

@interface YuneecRemoteControllerDataTransfer : NSObject

@property (nonatomic, weak, nullable) id<YuneecRemoteControllerDataTransferDelegate>    delegate;

- (void)sendData:(NSData *) data;

- (void)sendOldProtocolData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
