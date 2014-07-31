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
const int kBeaconMajorNumber = 101;

const NSInteger kSSBeaconThresholdImmediate = -70;
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
