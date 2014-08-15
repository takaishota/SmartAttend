//
//  PulseView.m
//  SmartShopping
//
//  Created by Shota Takai on 2014/06/26.
//
//

#import "PulseView.h"
#import <CoreLocation/CoreLocation.h>

@implementation PulseView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // 色自体はレイヤーで表現するので自分自身のviewの背景は透明にする
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupHaloLayer
{
    PulsingHaloLayer *haloLayer = [PulsingHaloLayer layer];
    haloLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self.layer addSublayer:haloLayer];
    self.haloLayer = haloLayer;
    self.haloLayer.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateViewStateWithBeacon:(CLBeacon *)beacon
{
    if (beacon.rssi < 0 && beacon.rssi >= kSSBeaconThresholdImmediate) {
        self.haloLayer.animationDuration = 1.2;
        self.haloLayer.backgroundColor = [[UIColor alizarinColor] CGColor];
        self.haloLayer.radius = 25;
        self.haloLayer.hidden = NO;
    }else {
        self.haloLayer.hidden = YES;
    }
    [self.haloLayer resetAnimation];
}

- (void) removeHaloLayer
{
    self.haloLayer.hidden = YES;
    self.haloLayer.sublayers = nil;
}

@end
