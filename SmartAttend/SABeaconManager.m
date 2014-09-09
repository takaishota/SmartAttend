//
//  SABeaconManager.m
//  Moully
//
//  Created by Shota Takai on 2014/07/29.
//
//

#import "SABeaconManager.h"
#import "SATimerManager.h"
#import "SALocalNotificationManager.h"
@import CoreLocation;

@interface SABeaconManager () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
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
        self.beaconRegion.notifyOnEntry = YES;
        self.beaconRegion.notifyOnExit = YES;
        self.beaconRegion.notifyEntryStateOnDisplay = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
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

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Enter");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exit");
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
    NSLog(@"didRangeBeacons");
    // 測定されたbeacon全てを通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:kRangingBeaconNotification object:beacons];
    
    if (!self.backgroundStatus) return;
    
    // バックグラウンド状態の場合、バックグラウンド通知を行う
    [self backgroundNotificate:beacons];
    
    // タイマーを起動する
    CLBeacon *beacon = [beacons firstObject];
    [[SATimerManager sharedManager] startTimer:beacon.major];
}

#pragma mark - Private

- (void)backgroundNotificate:(NSArray *)beacons {
    CLBeacon *beacon = [beacons firstObject];
    NSString *message = [NSString new];
    
    switch ([beacon.major intValue]) {
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

//アプリが非アクティブになりバックグラウンド実行になった際に呼び出される
- (void)applicationDidEnterBackground
{
    if ([CLLocationManager locationServicesEnabled])
    {
        // 位置情報サービスをバックグラウンドで起動する
        [[SABeaconManager sharedManager] startDetectingBeacon];
        self.locationManager.delegate = self;
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        [self.locationManager startUpdatingLocation];
        
        [self startDetectingBeacon];
    }
    self.backgroundStatus = YES;
}

@end