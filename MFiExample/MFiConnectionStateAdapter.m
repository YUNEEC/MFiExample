
#import "MFiConnectionStateAdapter.h"

#import <UIKit/UIKit.h>

#import <YuneecDataTransferManager/YuneecDataTransferConnectionState.h>
#import <YuneecDataTransferManager/YuneecDataTransferManager.h>
#import <YuneecDataTransferManager/YuneecControllerDataTransfer.h>

#import "c_library_v2/yuneec/mavlink.h"

@interface MFiConnectionStateAdapter() <YuneecDataTransferConnectionStateDelegate, YuneecFlyingControllerDataTransferDelegate>

@property (assign, nonatomic, readwrite) BOOL                       connected;
@property (assign, nonatomic, readwrite) BOOL                       bIsBackground;
@property (assign, nonatomic) YuneecDataTransferConnectionType      connectionType;
@property (strong, nonatomic) YuneecDataTransferConnectionState     *connectionState;

@property (strong, nonatomic) dispatch_source_t     heartbeatTimer;

@end

@implementation MFiConnectionStateAdapter

int numMessagesReceived = 0;
int numMessagesSent = 0;

NSString * const kMFiConnectionStateNotification = @"MFiConnectionStateNotification";

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
        [[YuneecDataTransferManager sharedInstance] controllerDataTransfer].flyingControllerDelegate = self;
    }
    return self;
}

- (void)dealloc {
    [self stopHeartbeatTimer];
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
    NSLog(@"connectionState started");
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
    NSDictionary* userInfo = @{@"MFiConnectionState": @(self.connected),
                               @"MFiConnectionType": @(self.connectionType),
                               @"BackgroundState": @(self.bIsBackground),
                               @"DroneMonitorLost":@(self.bDroneMonitorLost),
                               @"NumMessagesReceived":@(numMessagesReceived),
                               @"NumMessagesSent":@(numMessagesSent)
                               };
    return userInfo;
}

#pragma mark - YuneecDataTransferConnectionStateDelegate

- (void)connectionState:(YuneecDataTransferConnectionState *) connectionState
   changeConnectionType:(YuneecDataTransferConnectionType) connectionType
               fromType:(YuneecDataTransferConnectionType) fromType
{
    if (connectionType != fromType) {
        if (connectionType == 2) {
            [self stopHeartbeatTimer];
        } else if (connectionType == 0) {
            [self startHeartbeatTimer];
        }
    }
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
        NSLog(@"YuneecDataTransferConnectionState initialized");
    }
    return _connectionState;
}

- (void)controllerDataTransfer:(YuneecControllerDataTransfer *) dataTransfer
didReceiveFlyingControllerData:(NSData *) data {
    numMessagesReceived++;
    [self notifyConnectionStateUpdate];
}

- (void)sendHeartbeatPackage {
    // Don't send if not connected (anymore).
    if (self.connectionType != 0) {
        return;
    }
    mavlink_message_t       message;
    mavlink_heartbeat_t     heartbeat;
    
    heartbeat.custom_mode   = 0;
    heartbeat.type          = MAV_TYPE_GCS;
    heartbeat.autopilot     = MAV_AUTOPILOT_INVALID;
    heartbeat.base_mode     = MAV_MODE_FLAG_MANUAL_INPUT_ENABLED|MAV_MODE_FLAG_SAFETY_ARMED;
    heartbeat.system_status = MAV_STATE_ACTIVE;
    heartbeat.mavlink_version= 3;
    
    uint16_t package_len = mavlink_msg_heartbeat_encode(5, 10, &message, &heartbeat);
    
    uint8_t *buf = (uint8_t *)malloc(package_len);
    uint16_t ret = mavlink_msg_to_send_buffer(buf, &message);
#pragma unused(ret)
    
    NSData *sendData = [[NSData alloc] initWithBytes:buf length:package_len];
    [self sendControllerDataToTransfer:sendData];
    free(buf);
    numMessagesSent++;
}

- (void)sendControllerDataToTransfer:(NSData *) data {
    [[[YuneecDataTransferManager sharedInstance] controllerDataTransfer] sendData:data];
}

- (void)startHeartbeatTimer {
    if (self.heartbeatTimer != nil) {
        return;
    }
    self.heartbeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    dispatch_source_set_timer(self.heartbeatTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0);
    
    dispatch_source_set_event_handler(self.heartbeatTimer, ^{
        [self sendHeartbeatPackage];
        NSLog(@"Sending heartbeat");
    });
    
    dispatch_resume(self.heartbeatTimer);
}

- (void)stopHeartbeatTimer {
    if (self.heartbeatTimer != nil) {
        dispatch_source_cancel(self.heartbeatTimer);
        self.heartbeatTimer = nil;
    }
}


@end
