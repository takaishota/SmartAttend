//
//  SALocalNotificationManager.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/08.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SALocalNotificationManager.h"

@implementation SALocalNotificationManager

#pragma mark - Scheduler

- (void)scheduleLocalNotifications:(NSString *)alertBody {
    // 一度通知を全てキャンセルする
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // 通知を設定する
    [self scheduleBackgroundNotification:alertBody];
}

- (void) scheduleBackgroundNotification:(NSString *)alertBody
{
    // 通知を作成する
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate new]];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = alertBody;
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
