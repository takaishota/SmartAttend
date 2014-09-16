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
#import "SATabBarDataManager.h"
#import "SAMessageManager.h"
#import <AudioToolbox/AudioServices.h>
#import "EAIntroView.h"
#import "SABackgroundNotificationManager.h"

static NSString * kMessageCellReuseIdentifier = @"MessageCell";

@interface SATimeLineViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, SAMessageManagerDelegate>
@property (strong, nonatomic) UICollectionView * messageCollectionView;
@property (nonatomic) FUISwitch *beaconSwitch;
@property (nonatomic) SAMessageManager *messagesManager;
@property(nonatomic) CGFloat beginScrollOffsetY;
-(IBAction)deleteAllMessages:(id)sender;
@end

@implementation SATimeLineViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // ビーコンからの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRangeBeacon:) name:kRangingBeaconNotification object:nil];
        // フォアグラウンドに移行したときの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:kApplicationWillEnterForeground object:nil];
        [self setupCollectionView];
        [SAMessageManager sharedManager].delegate = self;
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
    
    self.parentViewController.navigationItem.title = @"CONNECT";
    
    // Add subviews.
    [self.view addSubview:self.messageCollectionView];
    [self scrollToBottom];
    
    // NavigationBarの設定
    [self initNavigationBar];
    
    if (!self.messageCollectionView) {
        self.messageCollectionView = [UICollectionView new];
    } else {
        [self.messageCollectionView reloadData];
    }
    
    [SABackgroundNotificationManager sharedManager].isBackground = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Collection View
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * message = [SAMessageManager sharedManager].messagesArray[indexPath.row];
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
    return [SAMessageManager sharedManager].messagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get Cell
    SAMessageCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMessageCellReuseIdentifier
                                                                                   forIndexPath:indexPath];
    NSMutableDictionary * message = [SAMessageManager sharedManager].messagesArray[indexPath.row];
    // メッセージの背景色、店舗アイコンを設定する
    cell.userColor = [self selectBackgroundColor:[[message objectForKey:@"shopId"] intValue]];
    cell.imageFileName = [NSString stringWithFormat:@"shopIcon%@", [message objectForKey:@"shopId"]];
    // メッセージをセットしたときにセルを描画している
    cell.message = message;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = [SAMessageManager sharedManager].messagesArray[indexPath.row];
    // タップされたら詳細画面に遷移する
    [self performSegueWithIdentifier:@"appearDetailView" sender:message];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - Scroll View Controller
//スクロールビューをドラッグし始めた際に一度実行される
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    self.beginScrollOffsetY = [scrollView contentOffset].y;

}

//スクロールビューがスクロールされるたびに実行され続ける
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (QVToolBarScrollStatusAnimation == [SATabBarDataManager sharedManager].toolBarScrollStatus
        || self.tabBarController.selectedIndex != 0) {
        return;
    }
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    if (self.beginScrollOffsetY < [scrollView contentOffset].y
        && !self.tabBarController.tabBar.hidden) {
        //スクロール前のオフセットよりスクロール後が多い=下を見ようとした
        [UIView animateWithDuration:0.3 animations:^{
            [SATabBarDataManager sharedManager].toolBarScrollStatus = QVToolBarScrollStatusAnimation;
            
            CGRect rect = tabBar.frame;
            tabBar.frame = CGRectMake(rect.origin.x,
                                            rect.origin.y + rect.size.height,
                                            rect.size.width,
                                            rect.size.height);
        } completion:^(BOOL finished) {
            
            tabBar.hidden = YES;
            [SATabBarDataManager sharedManager].toolBarScrollStatus = QVToolBarScrollStatusInit;
        }];
    } else if ([scrollView contentOffset].y < self.beginScrollOffsetY
               && tabBar.hidden
               && 0.0 != self.beginScrollOffsetY) {
        tabBar.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [SATabBarDataManager sharedManager].toolBarScrollStatus = QVToolBarScrollStatusAnimation;
            
            CGRect rect = tabBar.frame;
            tabBar.frame = CGRectMake(rect.origin.x,
                                            rect.origin.y - rect.size.height,
                                            rect.size.width,
                                            rect.size.height);
        } completion:^(BOOL finished) {
            
            [SATabBarDataManager sharedManager].toolBarScrollStatus = QVToolBarScrollStatusInit;
        }];
    }
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
        [[SAMessageManager sharedManager] didEnteringBeaconArea:beacons];
    }
}

// フォアグラウンド移行時
- (void)applicationWillEnterForeground
{
    // コレクションビューにデータを読み込む
    [self.messageCollectionView reloadData];
    [self.messageCollectionView layoutIfNeeded];
    [self scrollToBottom];
    // デリゲートを再度設定する
    [SAMessageManager sharedManager].delegate = self;
}

#pragma mark - MessageManager delegate
- (void)addMessageHandler:(NSMutableDictionary *)newMessage
{
    [self addNewMessageView:newMessage];
    // バイブ
    for (int i = 1; i < 2; i++) {
        [self performSelector:@selector(vibe) withObject:self afterDelay:i *.5f];
    }
    // 着信音
    [self notificationSound];
}

#pragma mark - Private
- (void) addNewMessageView:(NSDictionary *)message {
    // CollectionViewの表示後に最下部に遷移する
    [self.messageCollectionView performBatchUpdates:^{
        if ([SAMessageManager sharedManager].messagesArray.count == 0) {
            [_messageCollectionView reloadData];
        } else {
            [_messageCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[SAMessageManager sharedManager].messagesArray.count -1 inSection:0]]];
        };
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
}

- (void)scrollToBottom {
    if ([SAMessageManager sharedManager].messagesArray.count > 0) {
        static NSInteger section = 0;
        NSInteger item = [self collectionView:self.messageCollectionView numberOfItemsInSection:section] - 1;
        if (item < 0)  {
            item = 0;
        }
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        [self.messageCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

- (void)initNavigationBar
{
    // UINavigationBarのUIをフラット化する
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
    
    // メッセージ削除ボタンを生成
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllMessages:)];
    deleteButton.tintColor = [UIColor midnightBlueColor];
    self.parentViewController.navigationItem.leftBarButtonItem = deleteButton;
    
    // ビーコン受信開始スイッチを生成
    self.beaconSwitch = [FUISwitch new];
    self.beaconSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBeaconOn"];
    [SABeaconManager sharedManager].isBeaconOn = self.beaconSwitch.on;
    
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
    self.parentViewController.navigationItem.rightBarButtonItems = @[rightButton];
    
    self.parentViewController.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
    // beacon測定スタート
    [[SABeaconManager sharedManager] startDetectingBeacon];
}

// ON/OFFスイッチ押下時
- (void)onChangeSwitch:(id)sender
{
    UISwitch *beaconSwitch = sender;
    if (beaconSwitch.on) {
        [self startBeacon];
        self.beaconSwitch.on = YES;
        [SABeaconManager sharedManager].isBeaconOn = YES;
    } else {
        [[SABeaconManager sharedManager] stopDetectingBeacon];
        self.beaconSwitch.on = NO;
        [SABeaconManager sharedManager].isBeaconOn = NO;
    }
    [self.beaconSwitch setOn:self.beaconSwitch.on animated:YES];
    
    // マップのユーザ位置を表示/非表示にする
    if ([self.delegate respondsToSelector:@selector(changeSwitch:)])
    {
        [self.delegate changeSwitch:beaconSwitch.on];
    }
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
    
    [self.messageCollectionView removeFromSuperview];
    self.messageCollectionView.dataSource = nil;
    self.messageCollectionView = nil;
    self.messageCollectionView.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super removeFromParentViewController];
}

#pragma mark - IBAction

-(IBAction) deleteAllMessages:(id)sender
{
    [[SAMessageManager sharedManager] deleteAllMessages:sender];
    [self.messageCollectionView reloadData];
}

@end
