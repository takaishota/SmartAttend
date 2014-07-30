//
//  SAConstants.h
//  Moully
//
//  Created by Masato OSHIMA on 2014/07/29.
//
//

#import <Foundation/Foundation.h>

@interface SAConstants : NSObject

/// ビーコンを初期化する際のidentifier
extern NSString *const kBeaconIdentifier;

/// ビーコン通知
extern NSString *const kRangingBeaconNotification;

extern const int kBeaconMajorNumber;

/// ビーコンを識別するためのUUID
+ (NSUUID *)ApplixBeconUUID;

@end
