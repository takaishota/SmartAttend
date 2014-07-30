//
//  SATableCellTableViewCell.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/30.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SATableCellTableViewCell.h"
#import <FlatUIKit.h>

@implementation SATableCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        CALayer *layer = [[CALayer alloc] init];
//        layer.backgroundColor = [[UIColor grayColor] CGColor];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - private
- (void)setFrame:(CGRect)frame
{
    CGFloat inset = self.inset.floatValue;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}

@end
