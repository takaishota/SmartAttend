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
@end

@implementation SADetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.toolBar.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
