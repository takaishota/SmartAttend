//
//  SAMessageCollectionViewCell.h
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/30.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 Who sent the message
 */
typedef enum {
    kSentByOpponent,
} SentBy;

// Used for shared drawing btwn self & chatController
FOUNDATION_EXPORT int const outlineSpace;
FOUNDATION_EXPORT int const maxBubbleWidth;

@interface SAMessageCollectionViewCell : UICollectionViewCell

/*
 Message Property
 */
@property (strong, nonatomic) NSDictionary *message;

/*!
 Opponent bubble color
 */
@property (strong, nonatomic) UIColor *opponentColor;
/*!
 User bubble color
 */
@property (strong, nonatomic) UIColor *userColor;
/*!
 Shop icon image file
 */
@property (strong, nonatomic) NSString *imageFileName;

@end
