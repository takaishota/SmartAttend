//
//  SAMasterViewController.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/30.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SAMasterViewController.h"
#import "SADetailViewController.h"
#import "SABeaconManager.h"
#import <CoreLocation/CoreLocation.h>
#import <FlatUIKit.h>
#import "SATableCellTableViewCell.h"

@interface SAMasterViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_objects;
}
@property (nonatomic) NSMutableArray *contents;
@property (nonatomic) BOOL isFirst;
@property (nonatomic) int padding;
@end

@implementation SAMasterViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRangeBeacon:) name:kRangingBeaconNotification object:nil];
        
        self.padding = 5;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRangingBeaconNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // UINavigationBarのUIをフラット化する
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
    
    // テーブルの設定
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.indicatorStyle = UITableViewCellAccessoryNone;
    CGRect frame = self.tableView.frame;
    frame.size.width = self.view.frame.size.width - (self.padding *2);
    CGPoint center = self.tableView.center;
    center.x = self.view.frame.size.width/2;
    self.tableView.delegate = self;

    UIImage *backgroundImage = [UIImage imageNamed:@"Wallpaper.png"];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    self.contents = [[NSMutableArray alloc] init];
    
    [self startBeacon];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"Cell";
    SATableCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row % 2) {
        // 奇数
        [cell configureFlatCellWithColor:[UIColor clearColor]
                           selectedColor:[UIColor clearColor]
                         roundingCorners:2.0];
    } else {
        //偶数
        [cell configureFlatCellWithColor:[UIColor cloudsColor]
                           selectedColor:[UIColor midnightBlueColor]
                         roundingCorners:2.0];
        cell.alpha = 0.8;
        
        // 格納されているお知らせ情報を表示
        if ([self.contents count] > 0) {
            NSString *message = self.contents[indexPath.row];
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"メジャー番号：%@", message];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    CGFloat height;
    if (indexPath.row % 2) {
        height = (CGFloat)10.0f;
    } else {
        height = (CGFloat)120.0f;
    }
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Notification

- (void)didRangeBeacon:(NSNotification *)notification
{
    NSArray *beacons = notification.object;
//    NSLog(@"%@", [beacons count] > 0 ? [beacons description] : @"beacon is not found");
    
    // ビーコンを探索
    if ([beacons count] > 0) {
        CLBeacon *beacon = [beacons firstObject];
        [self didEnteringBeaconArea:beacon];
    }
}

- (void)didEnteringBeaconArea:(CLBeacon *)beacon
{
    if (![self.contents containsObject:beacon.major]) {
        [self.contents addObject:beacon.major];
        
        // テーブルビューを再描画する
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
        });

        NSLog(@"message%@", beacon.major);
    }
    
}


#pragma mark - Private
- (void)startBeacon
{
    // バッググラウンド更新が出来るか確認
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
        [self showAlert:@"バックグラウンド更新が無効です。「設定」を確認してください。"];
        return;
    }
    // iBeaconに対応しているかを調べます。
    if (![SABeaconManager sharedManager].isBeaconMonitoringAvailable) {
        [self showAlert:@"iBeaconのリージョンモニタリング機能がありません。"];
        return;
    }
    if (![SABeaconManager sharedManager].isBeaconRangingAvailable) {
        [self showAlert:@"iBeaconの受信機能がありません。"];
        return;
    }
    
    // beacon測定スタート
    [[SABeaconManager sharedManager] startDetectingBeacon];
}

- (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
