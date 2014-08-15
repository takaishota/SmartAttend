//
//  PulseView.h
//  SmartShopping
//
//  Created by Shota Takai on 2014/06/26.
//
//

#import <UIKit/UIKit.h>
#import "PulsingHaloLayer.h"
#import <CoreLocation/CoreLocation.h>

@interface PulseView : UIView

/// PulsingHaloLayerライブラリのレイヤー
@property (nonatomic) PulsingHaloLayer *haloLayer;
/// パルスを表現しているレイヤーを初期設定する
- (void)setupHaloLayer;
- (void)updateViewStateWithBeacon:(CLBeacon *)beacon;

@end
