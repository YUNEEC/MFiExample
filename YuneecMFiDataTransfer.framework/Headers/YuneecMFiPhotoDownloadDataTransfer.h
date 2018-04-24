//
//  YuneecMFiPhotoDownloadDataTransfer.h
//  YuneecMFiDataTransfer
//
//  Created by hank on 26/03/2018.
//  Copyright © 2018 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YuneecMFiPhotoDownloadDataTransfer;

@protocol YuneecMFiPhotoDownloadDataTransferDelegate<NSObject>

@required

/**
 * call this delegate when receive photo download data
 *
 * @param dataTransfer YuneecMFiPhotoDownloadDataTransfer instance
 * @param data photo download protocol bytes
 */
- (void)MFiPhotoDownloadDataTransfer:(YuneecMFiPhotoDownloadDataTransfer *) dataTransfer
                      didReceiveData:(NSData *) data;

@end


@interface YuneecMFiPhotoDownloadDataTransfer : NSObject

@property (nonatomic, weak, nullable) id<YuneecMFiPhotoDownloadDataTransferDelegate> delegate;

- (void)sendData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
