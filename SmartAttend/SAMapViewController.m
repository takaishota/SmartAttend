//
//  SAMapViewController.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/30.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SAMapViewController.h"
#import "SABeaconManager.h"
#import "PulseView.h"
#import <CoreLocation/CoreLocation.h>
#import "SATabBarDataManager.h"
#import "SATimeLineViewController.h"

@interface SAMapViewController () <SATimeLineViewControllerDelegate>
@property (nonatomic, weak) IBOutlet PulseView *pulseView;
@end

@implementation SAMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRangeBeacon:) name:kRangingBeaconNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SATabBarDataManager sharedManager].toolBarScrollStatus = QVToolBarScrollStatusInit;
    SATimeLineViewController *timeViewController  = [[self.tabBarController viewControllers] objectAtIndex:0];
    timeViewController.delegate = self;
    
    // Do any additional setup after loading the view.
    [self.pulseView setupHaloLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRangingBeaconNotification object:nil];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Notification Handler

-(void)didRangeBeacon:(NSNotification *)notification
{
    NSArray *beacons = notification.object;
    
    // ビーコンを探索
    CLBeacon *foundBeacon = nil;
    for (CLBeacon *beacon in beacons) {
        foundBeacon = beacon;
        break;
    }
    if (foundBeacon.rssi < 0 && foundBeacon.rssi > kSSBeaconThresholdImmediate ) {
        switch ([foundBeacon.major intValue]) {
            case kKitchenGoods:
                self.pulseView.center = CGPointMake(self.pulseView.center.x, 416);
                break;
            case kGinzaCrepe:
                self.pulseView.center = CGPointMake(self.pulseView.center.x, 336);
                break;
            case kShiodomeCream:
                self.pulseView.center = CGPointMake(self.pulseView.center.x, 256);
                break;
            case kFashionStore:
                self.pulseView.center = CGPointMake(self.pulseView.center.x, 176);
                break;
            default:
                break;
        }
        [self.pulseView updateViewStateWithBeacon:foundBeacon];
    }
}

#pragma mark - SATimelineViewController Delegate
- (void) changeSwitch:(BOOL)isOn
{
    if (isOn) {
        self.pulseView.hidden = NO;
    } else {
        self.pulseView.hidden = YES;
    }
}

@end
