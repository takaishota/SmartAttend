//
//  SAConstants.m
//  SmartShopping
//
//  Created by Masato OSHIMA on 2014/06/02.
//
//

#import "SAConstants.h"

@implementation SAConstants

NSString *const kBeaconIdentifier = @"Netcom";
NSString *const kRangingBeaconNotification = @"RangingBeaconNotification";
NSString *const kFinishTimerNotification = @"FinishTimerNotification";
NSString *const kFinishBackgroundLaunchingNotification = @"FinishBackgroundLaunchingNotification";
NSString *const kWillTerminateNotification = @"WillTerminateNotification";

// 一度表示した店舗のメッセージが表示されない時間(s)
const int kMessageDisableTime = 20;

const NSInteger kSSBeaconThresholdImmediate = -75;
//const NSInteger kSSBeaconThresholdNear = -90;
//const NSInteger kSSBeaconPThresholdFar = -999;

+ (NSUUID *)ApplixBeconUUID
{
    static NSUUID *uuid;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uuid = [[NSUUID alloc] initWithUUIDString:@"00000000-7257-1001-B000-001C4D470726"];
    });
    return uuid;
}

@end
