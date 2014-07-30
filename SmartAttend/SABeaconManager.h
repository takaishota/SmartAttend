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
 カタログ画面表示エリア内にいるかどうか
 
 YES:エリア内にいる NO:エリア外
 */
@property (nonatomic) BOOL isInsideProductArea;

/**
 現在表示している商品と紐づくMajorの値
 */
@property (nonatomic) NSNumber *selectedMajor;


@end
