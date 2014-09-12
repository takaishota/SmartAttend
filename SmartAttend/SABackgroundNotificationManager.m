//
//  SABackgroundNotificationManager.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/09/09.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SABackgroundNotificationManager.h"
#import "SALocalNotificationManager.h"
#import "SABeaconManager.h"
#import "SAMessageManager.h"

@interface SABackgroundNotificationManager () <SAMessageManagerDelegate>
@end

@implementation SABackgroundNotificationManager

+ (SABackgroundNotificationManager*)sharedManager
{
    static SABackgroundNotificationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SABackgroundNotificationManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        // ユーザによりバックグラウンド状態にされたときの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:kApplicationDidEnterBackgroundNotification object:nil];
        // バックグラウンドからフォアグラウンド状態にされたときの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:kApplicationWillEnterForeground object:nil];
        // 未起動状態からOSによりバックグラウンド起動されたときの通知
        // ビーコンからの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRangeBeacon:) name:kRangingBeaconNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationWillEnterForeground object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishBackgroundLaunchingNotification object:nil];
}

#pragma mark - private

- (void)backgroundNotificate:(int)shopId {
    NSString *message = [NSString new];
    
    switch (shopId) {
        case kKitchenGoods:
            message = @"キッチン雑貨マザーでセール開催中！";
            break;
        case kGinzaCrepe:
            message = @"銀座クレープでクーポン配布中！";
            break;
        case kShiodomeCream:
            message = @"汐留クリームでクーポン配布中！";
            break;
        case kFashionStore:
            message = @"ファッションストアでサマーセール開催中！";
            break;
        default:
            message = @"全店でセール開催中！";
            break;
    }
    [self sendNotification:message];
}

- (void)sendNotification:(NSString*)message
{
    // 通知を作成する
    SALocalNotificationManager *notificationManager = [SALocalNotificationManager new];
    [notificationManager scheduleLocalNotifications:message];
}

#pragma mark - SAMessageManager Delegate
- (void)addMessageHandler:(NSMutableDictionary *)newMessage
{
    // バックグラウンド状態の場合
    if (self.isBackground)
    {
        [self backgroundNotificate:[newMessage[@"shopId"] intValue]];
    }
}

#pragma mark- Notification

// フォアグラウンド移行時
- (void)applicationWillEnterForeground
{
    self.isBackground = NO;
}

// バックグラウンド移行時
- (void)applicationDidEnterBackground
{
    self.isBackground = YES;
    if ([SABeaconManager sharedManager].isBeaconOn) {
    // ビーコン監視のサービスを開始する
        [[SABeaconManager sharedManager] startDetectingBeacon];
        [SAMessageManager sharedManager].delegate = self;
    }
}

// アプリ未起動時
-(void)didFinishLaunchingWithBackground:(NSNotification *)notification
{
    // ビーコン監視のサービスを開始する
    self.isBackground = YES;
    NSLog(@"didFinishLaunchingWithBackground");
    [[SABeaconManager sharedManager] startDetectingBeacon];
    [SAMessageManager sharedManager].delegate = self;
}

// ビーコン電波受信時
- (void)didRangeBeacon:(NSNotification *)notification
{
    NSArray *beacons = notification.object;
    if ([beacons count] > 0) {
        [[SAMessageManager sharedManager] didEnteringBeaconArea:beacons];
    }
}

@end
