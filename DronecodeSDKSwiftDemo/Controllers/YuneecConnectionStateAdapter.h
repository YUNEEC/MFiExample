//
//  YuneecConnectionStateAdapter.h
//  YuneecPreviewDemo
//
//  Created by tbago on 07/02/2018.
//  Copyright © 2018 yuneec. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kConnectionStateNotification;

@interface YuneecConnectionStateAdapter : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitorConnectionState;

@end
