//
//  SATimerManager.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/01.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SATimerManager.h"

@interface SATimerManager ()
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishTimerNotification object:nil];
}

- (void)startTimer:(NSNumber *)identifier
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kMessageDisableTime
                                                  target:self
                                                    selector:@selector(stopTimer:)
                                                userInfo:identifier
                                                 repeats:NO];
    // 非同期でタイマーを動かす
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"タイマーをスタートしました");
    
    // タイマーオブジェクトを配列に追加する
    [self.timerQueue addObject:timer];
}

- (void)stopTimer:(id)identifier
{
    // 再表示不可の時間を過ぎたタイマーを止める
    if (self.timerQueue.count > 0 && [[self.timerQueue objectAtIndex:0] isValid]) {
        
        // タイマー オブジェクトを配列から削除する
        id object = nil;
        if(self.timerQueue.count > 0) {
            object = [self.timerQueue objectAtIndex:0];
            
            // 取り出したobjectを削除する
            [self.timerQueue removeObjectAtIndex:0];
            
            // タイマーが完了したことを通知する
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishTimerNotification object:[identifier userInfo]];

            [object invalidate];
            NSLog(@"タイマーを止めました");
        }
    }
}

@end
