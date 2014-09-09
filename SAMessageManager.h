//
//  SAMessageManager.h
//  SmartAttend
//
//  Created by Shota Takai on 2014/09/08.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SAMessageManagerDelegate <NSObject>
- (void)addMessageHandler:(NSMutableDictionary *)newMessage;
@end

@interface SAMessageManager : NSObject
@property (strong, nonatomic) NSMutableArray *messagesArray;

+ (SAMessageManager*)sharedManager;
- (void)didEnteringBeaconArea:(NSArray *)beacons;
-(void)deleteAllMessages:(id)sender;

@property (nonatomic, assign) id<SAMessageManagerDelegate> delegate;
@end
