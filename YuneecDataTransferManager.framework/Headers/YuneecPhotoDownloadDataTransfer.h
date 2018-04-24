//
//  YuneecPhotoDownloadDataTransfer.h
//  YuneecDataTransferManager
//
//  Created by hank on 26/03/2018.
//  Copyright © 2018 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecPhotoDownloadDataTransfer;

@protocol YuneecPhotoDownloadDataTransferDelegate <NSObject>

@required
- (void)photoDownloadDataTranfer:(YuneecPhotoDownloadDataTransfer *) dataTransfer
                  didReceiveData:(NSData *) data;

@end

@interface YuneecPhotoDownloadDataTransfer : NSObject

@property (nonatomic, weak, nullable) id<YuneecPhotoDownloadDataTransferDelegate>    delegate;

- (void)sendData:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
