//
//  SABeaconManager.m
//  Moully
//
//  Created by Shota Takai on 2014/07/29.
//
//

#import "SABeaconManager.h"
@import CoreLocation;

@interface SABeaconManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) BOOL backgroundStatus;

@end

@implementation SABeaconManager

+ (SABeaconManager*)sharedManager
{
    static SABeaconManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SABeaconManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[SAConstants ApplixBeconUUID] identifier:kBeaconIdentifier];
        self.isInsideProductArea = NO;
        
        NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
        [notification addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    }
    return self;
}

- (void)startDetectingBeacon
{
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)stopDetectingBeacon
{
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (BOOL)isBeaconMonitoringAvailable
{
    return [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
}

- (BOOL)isBeaconRangingAvailable
{
    return [CLLocationManager isRangingAvailable];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [manager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            // 領域内にいるので、beaconの距離計測(ranging)を開始する
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
            }
            break;
        case CLRegionStateOutside:
            break;
        case CLRegionStateUnknown:
            break;
        default:
            break;
    }
}

// ビーコンの領域内にいるときに断続的に呼び出されるデリゲートメソッド
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // 測定されたbeacon全てを通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:kRangingBeaconNotification object:beacons];
    
    // バックグラウンド時の通知
    [self backgroundNotificate:beacons];
}

- (void)backgroundNotificate:(NSArray *)beacons {
    // 有効なBeaconを1つ取り出す
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proximity != %d", CLProximityUnknown];
    NSArray *validBeacons = [beacons filteredArrayUsingPredicate:predicate];
    CLBeacon *beacon = validBeacons.firstObject;
    
    switch ([beacon.major intValue]) {
        case 1:
            [self sendNotification:@"キッチン雑貨マザーでセール開催中！"];
            break;
        case 2:
            [self sendNotification:@"銀座クレープでクーポン配布中！"];
            break;
        default:
            [self sendNotification:@"全店でセール開催中！"];
            break;
    }
    
    // 距離観測を終了する
    if (self.backgroundStatus) {
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (void)sendNotification:(NSString*)message
{
    // 通知を作成する
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate dateWithTimeInterval:10 sinceDate:[NSDate new]];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = @"Open";
//    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

//アプリが非アクティブになりバックグラウンド実行になった際に呼び出される
- (void)applicationDidEnterBackground
{
    self.backgroundStatus = YES;
    #if defined(DEBUG)
    NSLog(@"self.backgroundStatus :%d", self.backgroundStatus);
        NSLog(@"applicationDidEnterBackground");
        // バックグラウンド時になった時の実行処理
    #endif
}


@end