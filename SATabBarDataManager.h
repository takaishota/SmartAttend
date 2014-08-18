//
//  SATabBarDataManager.h
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/18.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SATabBarDataManager : NSObject
@property(nonatomic) BOOL toolBarScrollStatus;
typedef enum {
    QVToolBarScrollStatusInit = 0,
    QVToolBarScrollStatusAnimation ,
}QVToolBarScrollStatus;

+ (SATabBarDataManager*)sharedManager;
@end
