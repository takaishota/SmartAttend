//
//  SATimeLineViewController.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/31.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SATimeLineViewController.h"
#import "SADetailViewController.h"
#import "SABeaconManager.h"
#import "SAMessageCollectionViewCell.h"
#import "SATimerManager.h"
#import <CoreLocation/CoreLocation.h>
#import <FlatUIKit.h>
#import <AudioToolbox/AudioServices.h>

static NSString * kMessageCellReuseIdentifier = @"MessageCell";

@interface SATimeLineViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView * messageCollectionView;
@property (nonatomic) FUISwitch *beaconSwitch;
@property (strong, nonatomic) NSMutableArray *messagesArray;
-(IBAction)deleteAllMessages:(id)sender;
@end

@implementation SATimeLineViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // ビーコンからの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRangeBeacon:) name:kRangingBeaconNotification object:nil];
        // タイマーが完了したときの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTimer:) name:kFinishTimerNotification object:nil];
        // OSによりバックグラウンド起動されたときの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLaunchingWithBackground:) name:kFinishBackgroundLaunchingNotification object:nil];
        // アプリケーションが終了する直前の通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:kWillTerminateNotification object:nil];
        [self setupCollectionView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRangingBeaconNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishTimerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishBackgroundLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWillTerminateNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"CONNECT";
    
    // Add subviews.
    [self.view addSubview:self.messageCollectionView];
    [self scrollToBottom];
    
    // UINavigationBarのUIをフラット化する
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
    
    // ビーコン受信開始スイッチを生成
    self.beaconSwitch = [FUISwitch new];
    self.beaconSwitch.on = NO;
    
    self.beaconSwitch.frame = CGRectMake(0, 0, 60, 26);
    // 「ON」状態の色
    self.beaconSwitch.onColor = [UIColor turquoiseColor];
    // 「OFF」状態の色
    self.beaconSwitch.offColor = [UIColor cloudsColor];
    // 「ON」状態の背景色
    self.beaconSwitch.onBackgroundColor = [UIColor midnightBlueColor];
    // 「OFF」状態の背景色
    self.beaconSwitch.offBackgroundColor = [UIColor silverColor];
    // 「OFF」状態のフォント
    self.beaconSwitch.offLabel.font = [UIFont boldFlatFontOfSize:14];
    // 「ON」状態のフォント
    self.beaconSwitch.onLabel.font = [UIFont boldFlatFontOfSize:14];
    [self.beaconSwitch addTarget:self action:@selector(onChangeSwitch:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] init];
    [rightButton setCustomView:self.beaconSwitch];
    self.navigationItem.rightBarButtonItems = @[rightButton];
    
    // メッセージ配列を初期化
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"messagesArray"];
    self.messagesArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (self.messagesArray != NULL) {
        [self.messageCollectionView reloadData];
    } else {
        self.messagesArray = [NSMutableArray array];
        if (!self.messageCollectionView) {
            self.messageCollectionView = [UICollectionView new];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * message = _messagesArray[indexPath.row];
    static int offset = 20;
    
    if (!message[kMessageSize]) {
        NSString * content = [message objectForKey:@"content"];
        
        NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:15.0f];
        attributes[NSStrokeColorAttributeName] = [UIColor darkTextColor];
        
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:content
                                                                       attributes:attributes];
        
        // Here's the maximum width we'll allow our outline to be // 260 so it's offset
        int maxTextLabelWidth = maxBubbleWidth - outlineSpace;
        
        CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxTextLabelWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
        message[kMessageSize] = [NSValue valueWithCGSize:rect.size];
        return CGSizeMake(width(_messageCollectionView), rect.size.height + offset);
    }
    else {
        return CGSizeMake(_messageCollectionView.bounds.size.width, [message[kMessageSize] CGSizeValue].height + offset);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get Cell
    SAMessageCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMessageCellReuseIdentifier
                                                                                   forIndexPath:indexPath];
    NSMutableDictionary * message = _messagesArray[indexPath.row];
    // メッセージの背景色、店舗アイコンを設定する
    cell.userColor = [self selectBackgroundColor:[[message objectForKey:@"shopId"] intValue]];
    cell.imageFileName = [NSString stringWithFormat:@"shopIcon%@", [message objectForKey:@"shopId"]];
    // メッセージをセットしたときにセルを描画している
    cell.message = message;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.messagesArray[indexPath.row];
    // タップされたら詳細画面に遷移する
    [self performSegueWithIdentifier:@"appearDetailView" sender:message];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"appearDetailView"]) {
        // ショップIDを渡す
        SADetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.selectedMessage = sender;
    }
}

#pragma mark - Notification

- (void)didRangeBeacon:(NSNotification *)notification
{
    NSArray *beacons = notification.object;
    // ビーコンを探索
    if ([beacons count] > 0) {
        [self didEnteringBeaconArea:beacons];
    }
}

- (void)didEnteringBeaconArea:(NSArray *)beacons
{
    // 近くにあるビーコンから順にコレクションビューに追加する
    for (int i = 0; i < beacons.count ;i++) {
        CLBeacon *beacon = beacons[i];
    
        // ビーコンが情報表示エリアの内側にある場合
        if (beacon.rssi < 0 && beacon.rssi >= kSSBeaconThresholdImmediate) {
            if (self.messagesArray == nil)
            {
                self.messagesArray = [NSMutableArray new];
            }
            [SABeaconManager sharedManager].addMajor = beacon.major;
            
            // 受信したことのない店舗の場合
            if (![[self.messagesArray valueForKeyPath:@"shopId"] containsObject:beacon.major])
            {
                [self addMessageView:beacon];
            } else {
                // 受信したことのある店舗の場合
                NSMutableArray *arraySelectedByShopId = [NSMutableArray array];
                for (NSDictionary *message in self.messagesArray) {
                    if ([message[@"shopId"] intValue] == [beacon.major intValue]) {
                        [arraySelectedByShopId addObject:message];
                    }
                }
                // 再表示が禁止時間を過ぎたメッセージのみ表示する
                if (([arraySelectedByShopId count] > 0
                    && ![[[arraySelectedByShopId valueForKeyPath:@"available"] lastObject] isEqual:@0])
                    || !self.messagesArray) {
                    [self addMessageView:beacon];
                }
            }
        } else {
            break;
        }
    }
}

// アプリ終了前
-(void)applicationWillTerminate
{
    // メッセージリストの要素のavailableを1：利用可能にする
    int lastIndex = [self.messagesArray count] - 1;
    [self.messagesArray[lastIndex] setObject:@1 forKey:@"available"];
    
    
    // メッセージリストをユーザデフォルトに保存する
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.messagesArray];
    [defaults setObject:data forKey:@"messagesArray"];
    [defaults synchronize];
}

// アプリ未起動時
-(void)didFinishLaunchingWithBackground:(NSNotification *)notification
{
    // ビーコン監視のサービスを開始する
    [SABeaconManager sharedManager].backgroundStatus = YES;
    [[SABeaconManager sharedManager] startDetectingBeacon];
}

- (void)addMessageView:(CLBeacon *)beacon{
    NSMutableDictionary * newMessage = [NSMutableDictionary new];
    newMessage[@"shopId"]= beacon.major;

    // 店舗ごとに内容を変更する
    switch ([newMessage[@"shopId"] intValue]) {
        case kKitchenGoods:
            newMessage[@"shopName"] = @"キッチン雑貨 マザー";
            newMessage[@"content"] = @"キッチン雑貨　マザーです。\n16：00から１時間限定のセール実施中。\nぜひ寄ってみてください。";
            break;
        case kGinzaCrepe:
            newMessage[@"shopName"] = @"銀座クレープ";
            newMessage[@"content"] = @"クレープショップ　銀座クレープです。\n7/1から夏季限定クレープ販売中。\nクーポンをレジで見せていただいたお客様限定。\nバナナ、マンゴー、ブルーベリーをいづれかのトッピングを無料で！";
            break;
        case kShiodomeCream:
            newMessage[@"shopName"] = @"汐留クリーム";
            newMessage[@"content"] = @"汐留クリームです。\n暑い夏にぴったり！北海道特選 濃厚バニラソフトクリームが好評発売中！\n北海道ミルクと国産卵黄をたっぷり使った当店自慢の濃厚ソフトクリームです♪\n北海道特選 濃厚バニラソフトクリーム　330円(税込)\nキッズサイズ　250円(税込)";
            break;
        case kFashionStore:
            newMessage[@"shopName"] = @"ファッションストア";
            newMessage[@"content"] = @"ファッションストアです。\n◆夏物最終セール開催中です！\n夏物セール品最終価格！(8/31まで！）\n※一部、セール対象外商品がございます。\n◆バッグ全品期間限定値引き！\n夏のレジャーにぴったりの物やお仕事に使える物、バッグ類全品期間限定値引き中！！(8/31まで！）";
            break;
        default:
            newMessage[@"shopName"] = @"ショッピングモール";
            newMessage[@"content"] = @"ショッピングモールからのお知らせです。現在全店セールを開催しています。\n8月から9月までやってます。\nみなさま、どうぞお越し下さい。";
            break;
    }

    newMessage[kMessageRuntimeSentBy] = [NSNumber numberWithInt:kSentByUser];
    [newMessage setObject:[NSNumber numberWithBool:NO] forKey:@"available"];
    
    [self addNewMessage:newMessage];

    // タイマーを起動する
    [[SATimerManager sharedManager] startTimer:newMessage[@"shopId"]];
    [SABeaconManager sharedManager].addMajor = beacon.major;

    // バイブ
    for (int i = 1; i < 2; i++) {
        [self performSelector:@selector(vibe) withObject:self afterDelay:i *.5f];
    }
    // 着信音
    [self notificationSound];
}

-(void)finishTimer:(NSNotification *)notification
{
    // タイマーが完了したらメッセージが再表示できるようにする
    for (NSMutableDictionary *message in self.messagesArray) {
        if (message[@"shopId"] == notification.object)
        {
            [message setObject:[NSNumber numberWithBool:YES] forKey:@"available"];
        }
    }
}

#pragma mark SETTERS | GETTERS

- (void) setMessagesArray:(NSMutableArray *)messagesArray {
    _messagesArray = messagesArray;
    // Fix if we receive Null
    if (![_messagesArray.class isSubclassOfClass:[NSArray class]] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"messagesArray"]) {
        _messagesArray = [NSMutableArray new];
    }
    if (self.messagesArray.count > 0) {
        [self.messageCollectionView reloadData];
    }
}

#pragma mark - Private

- (void)addNewMessage:(NSDictionary *)message {
    if (_messagesArray == nil) {
        _messagesArray = [NSMutableArray new];
    }
    
    // データソースにオブジェクトを追加
    [_messagesArray addObject:message];
    // CollectionViewの表示後に最下部に遷移する
    [self.messageCollectionView performBatchUpdates:^{
        if (self.messagesArray.count == 0) {
            [_messageCollectionView reloadData];
        } else {
            [_messageCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messagesArray.count -1 inSection:0]]];
        };
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
}

- (void)scrollToBottom {
    if (self.messagesArray.count > 0) {
        static NSInteger section = 0;
        NSInteger item = [self collectionView:self.messageCollectionView numberOfItemsInSection:section] - 1;
        if (item < 0)  {
            item = 0;
        }
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        [self.messageCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

- (void) setupCollectionView
{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.sectionInset = UIEdgeInsetsMake(80, 0, 10, 0);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 6;
    
    CGRect collectionViewFrame = CGRectMake(0, 0, ScreenWidth(), ScreenHeight());
    self.messageCollectionView = [[UICollectionView alloc]initWithFrame:collectionViewFrame collectionViewLayout:flowLayout];
    self.messageCollectionView.backgroundColor = [UIColor whiteColor];
    self.messageCollectionView.delegate = self;
    self.messageCollectionView.dataSource = self;
    self.messageCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.messageCollectionView registerClass:[SAMessageCollectionViewCell class]
                forCellWithReuseIdentifier:kMessageCellReuseIdentifier];
}

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

// ON/OFFスイッチ押下時
- (void)onChangeSwitch:(id)sender
{
    UISwitch *beaconSwitch = sender;
    if (beaconSwitch.on) {
        [self startBeacon];
        self.beaconSwitch.on = YES;
    } else {
        [[SABeaconManager sharedManager] stopDetectingBeacon];
        self.beaconSwitch.on = NO;
    }
    [self.beaconSwitch setOn:self.beaconSwitch.on animated:YES];
	return;
}

-(void)vibe
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
- (void)notificationSound
{
    AudioServicesPlaySystemSound(1002);
}

- (UIColor*)selectBackgroundColor:(int)colorNumber {
    UIColor *color;
    switch (colorNumber) {
        case kKitchenGoods:
            color = [UIColor carrotColor];
            break;
        case kGinzaCrepe:
            color = [UIColor emerlandColor];
            break;
        case kShiodomeCream:
            color = [UIColor sunflowerColor];
            break;
        case kFashionStore:
            color = [UIColor alizarinColor];
            break;
        case 105:
            color = [UIColor turquoiseColor];
            break;
        case 106:
            color = [UIColor peterRiverColor];
            break;
        default:
            color = [UIColor amethystColor];
            break;
    }
    return color;
}

#pragma mark CLEAN UP

- (void) removeFromParentViewController {
    
    [self.messagesArray removeAllObjects];
    self.messagesArray = nil;
    
    [self.messageCollectionView removeFromSuperview];
    self.messageCollectionView.dataSource = nil;
    self.messageCollectionView = nil;
    
    self.messageCollectionView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super removeFromParentViewController];
}

#pragma mark - Outlet

-(IBAction) deleteAllMessages:(id)sender
{
    // ユーザデフォルトを初期化する
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    // メッセージリストを削除してテーブルを再読み込みする
    [self.messagesArray removeAllObjects];
    self.messagesArray = nil;
    [self.messageCollectionView reloadData];
}

@end
