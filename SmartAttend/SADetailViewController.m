//
//  SADetailViewController.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/30.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SADetailViewController.h"

@interface SADetailViewController ()
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIImageView *shopIcon;
@property (nonatomic, weak) IBOutlet UILabel *shopName;
@property (nonatomic, weak) IBOutlet UILabel *description;
@property (nonatomic, weak) IBOutlet UIImageView *couponImage;
@property (nonatomic, weak) IBOutlet UILabel *expiredFrom;
@property (nonatomic, weak) IBOutlet UILabel *expiredTo;
@end

@implementation SADetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.toolBar.backgroundColor = [UIColor clearColor];
    
    NSNumber *shopId = [self.selectedMessage objectForKey:@"shopId"];
    NSLog(@"shopId---- %@", shopId);
    
    self.shopIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"shopIcon%@.png", shopId]];
    self.shopName.text = [self.selectedMessage objectForKey:@"shopName"];
    self.description.text = [self.selectedMessage objectForKey:@"content"];
    self.couponImage.image = [UIImage imageNamed:@"couponImage.jpg"];
    self.expiredFrom.text = @"2014/8/31 16:00";
    self.expiredTo.text = @"2014/8/31 18:00";
    
    [self.description setLineBreakMode:NSLineBreakByWordWrapping];
    [self.description setNumberOfLines:0];
    [self.description sizeToFit];
    
    NSLog(@"text: %@", self.shopName.text);
    NSLog(@"fileNmae:%@", [UIImage imageNamed:[NSString stringWithFormat:@"shopIcon%@.png", shopId]]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
