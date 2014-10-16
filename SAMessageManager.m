//
//  SAMessageManager.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/09/08.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SAMessageManager.h"
#import <CoreLocation/CoreLocation.h>
#import "SABeaconManager.h"
#import "SATimerManager.h"

@implementation SAMessageManager

+ (SAMessageManager*)sharedManager
{
    static SAMessageManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SAMessageManager alloc] initSharedInstance];
    });
    return sharedInstance;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        // アプリケーションが終了する直前の通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:kWillTerminateNotification object:nil];
        
        // タイマーが完了したときの通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTimer:) name:kFinishTimerNotification object:nil];
        
        // メッセージ配列を初期化
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"messagesArray"];
        if (data) {
            self.messagesArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishTimerNotification object:nil];
}

#pragma mark - private
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
                [self addMessage:beacon];
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
                    [self addMessage:beacon];
                }
            }
        }
    }
}

- (void)addMessage:(CLBeacon *)beacon
{
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
    
    [newMessage setObject:[NSNumber numberWithBool:NO] forKey:@"available"];
    [SABeaconManager sharedManager].addMajor = beacon.major;
    
    // データソースにオブジェクトを追加
    [_messagesArray addObject:newMessage];
    
    if ([self.delegate respondsToSelector:@selector(addMessageHandler:)])
    {
        [self.delegate addMessageHandler:newMessage];
    }
    
    // タイマーを起動する
    [[SATimerManager sharedManager] startTimer:newMessage[@"shopId"]];
}

-(void)deleteAllMessages:(id)sender
{
    // ユーザデフォルトを初期化する
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    // メッセージリストを削除してテーブルを再読み込みする
    [self.messagesArray removeAllObjects];
    self.messagesArray = nil;
}

#pragma mark - notification
// アプリ終了時
-(void)applicationWillTerminate
{
    // メッセージリストの要素のavailableを1：利用可能にする
    int lastIndex = (int)([self.messagesArray count] - 1);
    [self.messagesArray[lastIndex] setObject:@1 forKey:@"available"];
    
    // メッセージリストをユーザデフォルトに保存する
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.messagesArray];
    [defaults setObject:data forKey:@"messagesArray"];
    [defaults synchronize];
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

- (void)setMessagesArray:(NSMutableArray *)messagesArray {
    _messagesArray = messagesArray;
    // Fix if we receive Null
    if (![_messagesArray.class isSubclassOfClass:[NSArray class]] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"messagesArray"]) {
        _messagesArray = [NSMutableArray new];
    }
    
}

@end
