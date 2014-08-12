//
//  SABeaconManager.h
//  SmartShopping
//
//  Created by Shota Takai on 2014/05/30.
//
//

#import <Foundation/Foundation.h>

@interface SABeaconManager : NSObject

+ (SABeaconManager*)sharedManager;

/**
 iBeaconの測定を開始する
 */
- (void)startDetectingBeacon;

/**
 iBeconaの測定を停止する
 */
- (void) stopDetectingBeacon;

/**
 iBeaconのリージョンモニタリング機能が利用可能かどうか
 
 YES:利用可能 NO:利用不可
 */
@property (nonatomic, readonly) BOOL isBeaconMonitoringAvailable;


/**
 iBeaconの距離計測機能が利用可能かどうか
 
 YES:利用可能 NO:利用不可
 */
@property (nonatomic, readonly) BOOL isBeaconRangingAvailable;

/**
 タイムラインに追加された最新の商品と紐づくMajorの値
 */
@property (nonatomic) NSNumber *addMajor;

/**
 バックグラウンド状態かどうか
 */
@property (nonatomic) BOOL backgroundStatus;

@end
