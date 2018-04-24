//
//  YuneecMFiRemoteControllerDataTransfer.h
//  YuneecMFiDataTransfer
//
//  Created by tbago on 27/11/2017.
//  Copyright © 2017 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecMFiRemoteControllerDataTransfer;

@protocol YuneecMFiRemoteControllerDataTransferDelegate <NSObject>

@required
- (void)MFiRemoteControllerDataTransfer:(YuneecMFiRemoteControllerDataTransfer *) dataTransfer
                         didReceiveData:(NSData *) data;

@end

@interface YuneecMFiRemoteControllerDataTransfer : NSObject

@property (nonatomic, weak, nullable) id<YuneecMFiRemoteControllerDataTransferDelegate>    delegate;

- (void)sendData:(NSData *) data;

- (void)sendOldProtocolData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
