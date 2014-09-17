//
//  SAViewController.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/08/01.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SAViewController.h"
#import "SATimeLineViewController.h"
#import "EAIntroView.h"

@interface SAViewController () <EAIntroDelegate>
@property(nonatomic,weak) IBOutlet EAIntroView *introView;
@end

@implementation SAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title=@"CONNECTでお買い物を楽しく！";
    page1.bgImage = [UIImage imageNamed:@"bg2"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigLogo"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title=@"お店からいろいろな情報をお届け";
    page2.desc = @"ショッピングモールを歩くだけで、各店舗から割引クーポンやお得なお知らせが届きます。タイムセールや期間限定のお得な情報も盛りだくさん！";
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_gift"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title=@"クーポンを見せてお得にショッピング";
    page3.desc = @"保存したクーポンはお店ですぐに使えて、お得なサービスがその場で利用できます！";
    page3.bgImage = [UIImage imageNamed:@"bg2"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_shopping"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title=@"迷うことなくお買い物";
    page4.desc = @"フロアマップに自分のいる場所が表示され、お店までの行き方が一目で分かります。迷うことなくお買い物ができます。";
    page4.bgImage = [UIImage imageNamed:@"bg2"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_map"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2, page3, page4]];
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

- (void)introDidFinish:(EAIntroView *)introView;
{
    [self performSegueWithIdentifier:@"TimeLineViewControllerSegue" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
