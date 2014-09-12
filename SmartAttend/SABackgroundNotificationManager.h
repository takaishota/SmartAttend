//
//  SABackgroundNotificationManager.h
//  SmartAttend
//
//  Created by Shota Takai on 2014/09/09.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SABackgroundNotificationManager : NSObject

+ (SABackgroundNotificationManager*)sharedManager;
-(void)didFinishLaunchingWithBackground:(NSNotification *)notification;

@property (nonatomic) BOOL isBackground;

@end
