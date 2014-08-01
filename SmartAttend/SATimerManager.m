//
//  SATimerManager.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/01.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SATimerManager.h"

@interface SATimerManager ()
//@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSMutableArray *timerQueue;
@end
@implementation SATimerManager

+ (SATimerManager*)sharedManager
{
    static SATimerManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SATimerManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        self.timerQueue = [NSMutableArray array];
    }
    return self;
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kMessageDisableTime
                                                  target:self
                                                selector:@selector(stopTimer)
                                                userInfo:nil
                                                 repeats:NO];
    
    // 非同期でタイマーを動かす
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    [self.timerQueue addObject:self.timer];
    
    NSLog(@"timerQueue: %@", self.timerQueue.description);
//    [self.timer fire];
    NSLog(@"タイマーをスタートしました");
}

- (void)stopTimer{
    // 再表示不可の時間を過ぎたタイマーを止める
    if ([self.timer isValid]) {
        [self.timer invalidate];
        NSLog(@"タイマーを止めました");
    }
}

@end
