//
//  TSMessageView.h
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"

#define TSMessageViewAlpha 0.95

#pragma mark - Design dictionary key values
#define TSDesignBackgroundImageName  @"backgroundImageName"
#define TSDesignBorderColor @"borderColor"
#define TSDesignBorderHeight @"borderHeight"
#define TSDesignButtonBackgroundImageName @"buttonBackgroundImageName"
#define TSDesignButtonTitleTextColor @"buttonTitleTextColor"
#define TSDesignButtonTitleShadowColor @"buttonTitleShadowColor"
#define TSDesignButtonTitleShadowOffsetX @"buttonTitleShadowOffsetX"
#define TSDesignButtonTitleShadowOffsetY @"buttonTitleShadowOffsetY"
#define TSDesignContentFontSize @"contentFontSize"
#define TSDesignContentTextColor @"contentTextColor"
#define TSDesignImageName @"imageName"
#define TSDesignImageBackgroundColor @"imageBackgroundColor"
#define TSDesignShadowColor @"shadowColor"
#define TSDesignShadowOffsetX @"shadowOffsetX"
#define TSDesignShadowOffsetY @"shadowOffsetY"
#define TSDesignTextColor @"textColor"
#define TSDesignTitleFontSize @"titleFontSize"


@interface TSMessageView : UIView

/** The displayed title of this message */
@property (nonatomic, readonly) NSString *title;

/** The displayed content of this message (optional) */
@property (nonatomic, readonly) NSString *content;

/** The view controller this message is displayed in */
@property (nonatomic, readonly) UIViewController *viewController;

/** The duration of the displayed message. If it is 0.0, it will automatically be calculated */
@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign) TSMessageNotificationPosition messagePosition;

/** Inits the notification view. Do not call this from outisde this library.
 @param title The title of the notification view
 @param content The subtitle/content of the notification view (optional)
 @param notificationType The type (color) of the notification view
 @param duration The duration this notification should be displayed (optional)
 @param viewController The view controller this message should be displayed in
 @param callback The block that should be executed, when the user tapped on the message
 @param buttonTitle The title for button (optional)
 @param buttonCallback The block that should be executed, when the user tapped on the button
 @param position The position of the message on the screen
 */
- (id)initWithTitle:(NSString *)title
        withContent:(NSString *)content
           withType:(TSMessageNotificationType)notificationType
       withDuration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
       withCallback:(void (^)())callback
    withButtonTitle:(NSString *)buttonTitle
 withButtonCallback:(void (^)())buttonCallback
         atPosition:(TSMessageNotificationPosition)position;

/** Fades out this notification view */

- (void)fadeMeOut;


/**
 * Method name:   setDefaultValuesForType
 *
 * Description:        Allows to setup a dictionary containing the values that will be used instead of the ones set into the design.json file. 
 *                              If any value is NOT defined here, won't be used when building the MessageView.
 * Parameters:        
 *          @param  notificationType Type of notification that will be override
 *          @param  defaultDictionary Dictionary containing the data that will be sued instead of the ones defined into the json file. The dictionary should be filled up using  TSDesign defines as keys
 * Returns:                
 *          @return    void
 */
+ (void) setDefaultValuesForType:(TSMessageNotificationType)notificationType withDictionary:(NSDictionary*)defaultDictionary;

@end
