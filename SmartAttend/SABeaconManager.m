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
#import "SABackgroundNotificationManager.h"
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
        
        // アプリケーションが終了する直前の通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:kWillTerminateNotification object:nil];
    }
    return self;
}

- (void)startDetectingBeacon
{
    // バッググラウンド更新が出来るか確認
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
        [self showAlert:@"バックグラウンド更新が無効です。「設定」を確認してください。"];
        return;
    }
    // iBeaconに対応しているかを調べます。
    if (![SABeaconManager sharedManager].isBeaconMonitoringAvailable) {
        [self showAlert:@"iBeaconのリージョンモニタリング機能がありません。"];
        return;
    }
    if (![SABeaconManager sharedManager].isBeaconRangingAvailable) {
        [self showAlert:@"iBeaconの受信機能がありません。"];
        return;
    }
    
    if ([SABackgroundNotificationManager sharedManager].isBackground) {
        self.locationManager.delegate = self;
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        [self.locationManager startUpdatingLocation];
    }
    
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
    // 取得したbeaconをオブジェクトにセットして通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:kRangingBeaconNotification object:beacons];
}

#pragma mark - Private

- (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - notification
- (void)applicationWillTerminate
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isBeaconOn"];
}

@end