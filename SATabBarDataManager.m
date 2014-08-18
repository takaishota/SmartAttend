//
//  SATabBarDataManager.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/18.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SATabBarDataManager.h"

@implementation SATabBarDataManager
+ (SATabBarDataManager*)sharedManager
{
    static SATabBarDataManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SATabBarDataManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        self.toolBarScrollStatus = QVToolBarScrollStatusInit;
    }
    return self;
}
@end
