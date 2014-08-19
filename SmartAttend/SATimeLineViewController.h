//
//  SATimeLineViewController.h
//  SmartAttend
//
//  Created by Shota Takai on 2014/07/31.
//  Copyright (c) 2014年 Shota Takai. All rights reserved.
//

#import <UIKit/UIKit.h>

// Message Dictionary Keys (defined in MessageCell)
FOUNDATION_EXPORT NSString * const kMessageSize;
FOUNDATION_EXPORT NSString * const kMessageContent;
FOUNDATION_EXPORT NSString * const kMessageRuntimeSentBy;
FOUNDATION_EXPORT NSString * const kShopId;

@protocol SATimeLineViewControllerDelegate <NSObject>
- (void) changeSwitch:(BOOL)isOn;
@end

@interface SATimeLineViewController : UIViewController

/*!
 The color of the user's chat bubbles
 */
@property (strong, nonatomic) UIColor * userBubbleColor;
/*!
 The color of the opponent's chat bubbles
 */
@property (strong, nonatomic) UIColor * opponentBubbleColor;

/*!
 Add new message to view
 */
- (void) addNewMessage:(NSDictionary *)message;

@property (nonatomic, assign) id<SATimeLineViewControllerDelegate> delegate;
@end
