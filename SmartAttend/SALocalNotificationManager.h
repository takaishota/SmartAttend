//
//  SALocalNotificationManager.h
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/08.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SALocalNotificationManager : NSObject
// ローカル通知を登録する
- (void)scheduleLocalNotifications:(NSString *)alertBody;
@end
