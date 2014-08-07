//
//  SATimerManager.h
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/01.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SATimerManager : NSObject
@property (nonatomic, strong) NSTimer *timer;
+ (SATimerManager*)sharedManager;

/**
 タイマーの測定を開始する
 */
- (void) startTimer:(NSNumber *)identifier;

/**
 停止時間を過ぎたタイマーの測定を停止する
 */
- (void) stopTimer:(NSTimer *)identifier;

/**
 全てのタイマーの測定を停止する
 */
- (void) stopAllTimer;

@end
