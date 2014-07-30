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
}

@end