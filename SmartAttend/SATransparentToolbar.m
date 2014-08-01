//
//  SATransparentToolbar.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/01.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SATransparentToolbar.h"

@implementation SATransparentToolbar

// Override draw rect to avoid
// background coloring
- (void)drawRect:(CGRect)rect {
    // do nothing in here
}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.translucent = YES;
}

// Override init.
- (id) init
{
    self = [super init];
    [self applyTranslucentBackground];
    return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    [self applyTranslucentBackground];
    return self;
}

@end
