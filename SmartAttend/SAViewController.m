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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title=@"CONNECT";
    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigLogo"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title=@"page2";
    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title2"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title=@"page3";
    page3.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    page3.bgImage = [UIImage imageNamed:@"bg1"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2, page3]];
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
