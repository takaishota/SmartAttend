//
//  SAMessageCollectionViewCell.m
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/30.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import "SAMessageCollectionViewCell.h"
#import "SABeaconManager.h"
#import <FlatUIKit.h>

// External Constants
int const outlineSpace = 24; // 11 px on each side for border
int const maxBubbleWidth = 260; // Max Bubble Size

NSString * const kMessageSize = @"size";
NSString * const kMessageContent = @"content";
NSString * const kMessageShopId = @"shopId";
NSString * const kMessageRuntimeSentBy = @"runtimeSentBy";


// Instance Level Constants
static int offsetX = 6; // 6 px from each side
// Minimum Bubble Height
static int minimumHeight = 30;

static CGFloat iconWidth = 40;
static CGFloat iconHeight = 40;

@interface SAMessageCollectionViewCell()
// Who Sent The Message
@property (nonatomic) SentBy sentBy;

// Received Size
@property CGSize textSize;

// Bubble, Text, ImgV
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UILabel *bgLabel;
@property (strong, nonatomic) UIImageView *shopIconImage;
@end

@implementation SAMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Dark Blue.
        self.opponentColor = [UIColor blueColor];
        
        // Light Blue
        if (!self.bgLabel) {
            self.bgLabel = [UILabel new];
            self.bgLabel.layer.borderWidth = 2;
            self.bgLabel.layer.cornerRadius = minimumHeight / 2;
            self.bgLabel.alpha = .900;
            [self.contentView addSubview:self.bgLabel];
        }
        
        if (!self.textLabel) {
            self.textLabel = [UILabel new];
            self.textLabel.layer.rasterizationScale = 2.0f;
            self.textLabel.layer.shouldRasterize = YES;
            self.textLabel.font = [UIFont systemFontOfSize:15.0f];
            self.textLabel.textColor = [UIColor whiteColor];
            self.textLabel.numberOfLines = 0;
            [self.contentView addSubview:self.textLabel];
        }
    }
    return self;
}

#pragma mark - private

- (void) setUserColor:(UIColor *)userColor {
    _userColor = userColor;
}

- (void) setMessage:(NSDictionary *)message {
    _message = message;
    [self drawCell];
}

- (void) drawCell {
    self.bgLabel.layer.backgroundColor = self.userColor.CGColor;
    // Get Our Stuff
    self.textSize = [self.message[kMessageSize] CGSizeValue];
    self.textLabel.text = self.message[kMessageContent];
    self.sentBy = [self.message[kMessageRuntimeSentBy] intValue];
    
    // 店舗画像の設定
    if (!self.shopIconImage) {
        self.shopIconImage = [UIImageView new];
        self.shopIconImage.image = [UIImage imageNamed:self.imageFileName];
        self.shopIconImage.frame =  CGRectMake(10, 10, iconWidth, iconHeight);
        self.shopIconImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.shopIconImage setClipsToBounds:YES];
        [self.contentView addSubview:self.shopIconImage];
    }
    
    // the height that we want our text bubble to be
    CGFloat height = self.contentView.bounds.size.height - 10;
    if (height < minimumHeight) {
        height = minimumHeight;
    }
    
        // then this is a message that the current user created . . .
        self.bgLabel.frame = CGRectMake(ScreenWidth() - offsetX, 0, - self.textSize.width - outlineSpace, height);
        self.bgLabel.layer.borderColor = self.userColor.CGColor;
    
    // position textLabel in the bgLabel;
    self.textLabel.frame = CGRectMake(self.bgLabel.frame.origin.x + (outlineSpace / 2), self.bgLabel.frame.origin.y + (outlineSpace / 2), self.bgLabel.bounds.size.width - outlineSpace, self.bgLabel.bounds.size.height - outlineSpace);
}

@end
