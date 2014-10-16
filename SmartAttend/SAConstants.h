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
/// タイマー完了通知
extern NSString *const kFinishTimerNotification;
/// iOSによるバックグラウンド起動時の通知
extern NSString *const kFinishBackgroundLaunchingNotification;
/// ユーザによるバックグラウンド移行時の通知
extern NSString *const kApplicationDidEnterBackgroundNotification;
/// バックグラウンドからフォアグラウンドに移行時の通知
extern NSString *const kApplicationWillEnterForeground;
/// 終了直前の通知
extern NSString *const kWillTerminateNotification;

// RSSIの閾値
extern const NSInteger kSSBeaconThresholdImmediate;
extern const NSInteger kSSBeaconThresholdNear;
extern const NSInteger kSSBeaconThresholdFar;

// 再表示しない秒数
extern const int kMessageDisableTime;

// 各店舗に対応するMajorの値
extern const int kKitchenGoods = 101;
extern const int kShiodomeCream = 102;
extern const int kGinzaCrepe = 103;
extern const int kFashionStore = 104;

/// ビーコンを識別するためのUUID
+ (NSUUID *)ApplixBeconUUID;

#ifndef MyMacros_h
#define MyMacros_h

static inline CGFloat width(UIView *view) { return view.frame.size.width; }
static inline CGFloat height(UIView *view) { return view.frame.size.height; }
static inline int ScreenHeight(){ return [UIScreen mainScreen].bounds.size.height; }
static inline int ScreenWidth(){ return [UIScreen mainScreen].bounds.size.width; }

static inline UIColor *AppLightBlueColor() {
    return [UIColor colorWithRed:30.0/255.0 green:174.0/255.0 blue:236.0/255.0 alpha:1.0];
}
static inline UIColor *AppDarkBlueColor() {
    return [UIColor colorWithRed:30/255.0 green:66.0/255.0 blue:147.0/255.0 alpha:1.0];
}
static inline NSString *InviteToChat(NSString *invitee) {
    return [NSString stringWithFormat:@"You were invited to chat by : %@", invitee];
}

#endif

@end
