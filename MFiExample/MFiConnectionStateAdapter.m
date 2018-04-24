
#import "MFiConnectionStateAdapter.h"

#import <UIKit/UIKit.h>

#import <YuneecDataTransferManager/YuneecDataTransferConnectionState.h>
#import <YuneecDataTransferManager/YuneecDataTransferManager.h>

@interface MFiConnectionStateAdapter() <YuneecDataTransferConnectionStateDelegate>

@property (assign, nonatomic, readwrite) BOOL                       connected;
@property (assign, nonatomic, readwrite) BOOL                       bIsBackground;
@property (assign, nonatomic) YuneecDataTransferConnectionType      connectionType;
@property (strong, nonatomic) YuneecDataTransferConnectionState     *connectionState;

@end

@implementation MFiConnectionStateAdapter

NSString * const kMFiConnectionStateNotification = @"kMFiConnectionStateNotification";

#pragma mark - init

+ (instancetype)sharedInstance {
    static MFiConnectionStateAdapter *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[MFiConnectionStateAdapter alloc] init];
    });
    return sInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bIsBackground = NO;
        self.connectionType = YuneecDataTransferConnectionTypeNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)applicationDidEnterBackground {
    self.bIsBackground = YES;
    // Notify connection state & type with background state to remove media player and other modules
    [self notifyConnectionStateUpdate];
}

- (void)applicationWillEnterForeground {
    self.bIsBackground = NO;
    if((self.connected) && (self.connectionType != YuneecDataTransferConnectionTypeNone)) {
        // Notify connection state & type with background state to recovery media player and other modules
        [self notifyConnectionStateUpdate];
    }
    else {
        [self startMonitorConnectionState];
    }
}

#pragma mark - public method

- (void)startMonitorConnectionState {
    [self.connectionState startMonitorConnectionState];
}

- (void)stopMonitorConnectionState {
    [self.connectionState stopMonitorConnectionState];
}

- (BOOL)getMFiConnectionState {
    if(self.connected && (self.connectionType == YuneecDataTransferConnectionTypeMFi)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSDictionary *)getConnectionStatus {
    NSDictionary* userInfo = @{@"OBConnectionState": @(self.connected),
                               @"OBConnectionType": @(self.connectionType),
                               @"BackgroundState": @(self.bIsBackground),
                               @"DroneMonitorLost":@(self.bDroneMonitorLost)};
    return userInfo;
}

#pragma mark - YuneecDataTransferConnectionStateDelegate

- (void)connectionState:(YuneecDataTransferConnectionState *) connectionState
   changeConnectionType:(YuneecDataTransferConnectionType) connectionType
               fromType:(YuneecDataTransferConnectionType) fromType
{

    self.connectionType = connectionType;
    [[YuneecDataTransferManager sharedInstance] setCurrentDataTransferType:connectionType];
    [self notifyConnectionStateUpdate];
}


#pragma mark - private methods
- (void) notifyConnectionStateUpdate {
    NSDictionary* userInfo = [self getConnectionStatus];
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMFiConnectionStateNotification object:nil userInfo:userInfo];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kMFiConnectionStateNotification object:nil userInfo:userInfo];
        });
    }
}

#pragma mark - get & set

- (YuneecDataTransferConnectionState *)connectionState {
    if (_connectionState == nil) {
        _connectionState = [[YuneecDataTransferConnectionState alloc] init];
        _connectionState.connectionDelegate = self;
    }
    return _connectionState;
}

@end
