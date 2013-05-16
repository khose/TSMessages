//
//  TSMessageView.m
//  Toursprung
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Toursprung. All rights reserved.
//

#import "TSMessageView.h"
#import "UIColor+MLColorAdditions.h"
#import "UIImage+MHUIColor.h"

#define TSMessageViewPadding 15.0

#define TSDesignFileName @"design.json"

static NSDictionary *notificationDesign;

static NSDictionary *successCustomDesign;
static NSDictionary *messageCustomDesign;
static NSDictionary *warningCustomDesign;
static NSDictionary *errorCustomDesign;

@interface TSMessageView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIViewController *viewController;

/** Internal properties needed to resize the view on device rotation properly */
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, assign) CGFloat textSpaceLeft;
@property (nonatomic, assign) CGFloat textSpaceRight;

@property (copy) void (^callback)();
@property (copy) void (^buttonCallback)();

- (CGFloat)updateHeightOfMessageView;
- (void)layoutSubviews;

@end


@implementation TSMessageView

- (id)initWithTitle:(NSString *)title
        withContent:(NSString *)content
           withType:(TSMessageNotificationType)notificationType
       withDuration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
       withCallback:(void (^)())callback
    withButtonTitle:(NSString *)buttonTitle
 withButtonCallback:(void (^)())buttonCallback
         atPosition:(TSMessageNotificationPosition)position
{
    if (!notificationDesign)
    {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:TSDesignFileName];
        notificationDesign = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                             options:kNilOptions
                                                               error:nil];
    }
    
    if ((self = [self init]))
    {
        _title = title;
        _content = content;
        _buttonTitle = buttonTitle;
        _duration = duration;
        _viewController = viewController;
        _messagePosition = position;
        self.callback = callback;
        self.buttonCallback = buttonCallback;
        
        CGFloat screenWidth = self.viewController.view.frame.size.width;
        NSDictionary *current;
        NSString *currentString;
        
        switch (notificationType)
        {
            case TSMessageNotificationTypeMessage:
            {
                if (messageCustomDesign) {
                    current =  messageCustomDesign;
                }
                else
                    currentString = @"message";
                
                break;
            }
            case TSMessageNotificationTypeError:
            {
                if (errorCustomDesign) {
                    current =  errorCustomDesign;
                }
                else
                    currentString = @"error";
                
                break;
            }
            case TSMessageNotificationTypeSuccess:
            {
                if (successCustomDesign) {
                    current =  successCustomDesign;
                }
                else
                    currentString = @"success";
                
                break;
            }
            case TSMessageNotificationTypeWarning:
            {
                if (warningCustomDesign) {
                    current =  warningCustomDesign;
                }
                else
                    currentString = @"warning";
                
                break;
            }
                
            default:
                break;
        }
        
        if(currentString)
            current = [notificationDesign valueForKey:currentString];
        
        self.alpha = 0.0;
        
        UIImage *image;
        if ([current valueForKey:@"imageName"])
        {
            image = [UIImage imageNamed:[current valueForKey:@"imageName"]];
        }
        
        // add background image here
        NSString *bgImageName = [current valueForKey:@"backgroundImageName"];
        UIImage *backgroundImage;
        if([bgImageName length])
        {
            if ([bgImageName hasPrefix:@"#"] ) {
                backgroundImage = [UIImage imageWithColorString:bgImageName];
            }
            else
                backgroundImage = [[UIImage imageNamed:[current valueForKey:@"backgroundImageName"]] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        }
        
        _backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        [self addSubview:self.backgroundImageView];
        
        UIColor *fontColor = [UIColor colorWithHexString:[current valueForKey:@"textColor"]
                                                   alpha:1.0];
        
        self.textSpaceLeft = 2 * TSMessageViewPadding;
        if (image) self.textSpaceLeft += image.size.width + 2 * TSMessageViewPadding;
        
        // Set up title label
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:title];
        [self.titleLabel setTextColor:fontColor];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        
        if([current valueForKey:@"titleFontSize"])
            [self.titleLabel setFont:[UIFont boldSystemFontOfSize:[[current valueForKey:@"titleFontSize"] floatValue]]];
        
        if([[current valueForKey:@"shadowColor"] length] )
        {
            [self.titleLabel setShadowColor:[UIColor colorWithHexString:[current valueForKey:@"shadowColor"] alpha:1.0]];
            [self.titleLabel setShadowOffset:CGSizeMake([[current valueForKey:@"shadowOffsetX"] floatValue],
                                                    [[current valueForKey:@"shadowOffsetY"] floatValue])];
        }
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];
        
        // Set up content label (if set)
        if ([content length])
        {
            _contentLabel = [[UILabel alloc] init];
            [self.contentLabel setText:content];
            
            if([[current valueForKey:@"contentTextColor"] length])
            {
                UIColor *contentTextColor = [UIColor colorWithHexString:[current valueForKey:@"contentTextColor"] alpha:1.0];
                if (!contentTextColor) {
                    contentTextColor = fontColor;
                }
                [self.contentLabel setTextColor:contentTextColor];
            }
            else
                [self.contentLabel setTextColor:[UIColor whiteColor]];

            [self.contentLabel setBackgroundColor:[UIColor clearColor]];
            if([current valueForKey:@"contentFontSize"])
                [self.contentLabel setFont:[UIFont systemFontOfSize:[[current valueForKey:@"contentFontSize"] floatValue]]];
            
            [self.contentLabel setShadowColor:self.titleLabel.shadowColor];
            [self.contentLabel setShadowOffset:self.titleLabel.shadowOffset];
            self.contentLabel.lineBreakMode = self.titleLabel.lineBreakMode;
            self.contentLabel.numberOfLines = 0;
            
            [self addSubview:self.contentLabel];
        }
        
        if (image)
        {
            _iconImageView = [[UIImageView alloc] initWithImage:image];
            self.iconImageView.frame = CGRectMake(TSMessageViewPadding * 2,
                                                  TSMessageViewPadding,
                                                  image.size.width,
                                                  image.size.height);
            
            if ([current valueForKey:@"imageBackgroundColor"]) {
                [self.iconImageView setBackgroundColor:[UIColor colorWithHexString:[current valueForKey:@"imageBackgroundColor"] alpha:1.0]];
            }
            else
                [self.iconImageView setBackgroundColor:[UIColor clearColor]];
            
            [self addSubview:self.iconImageView];
        }
        
        // Set up button (if set)
        if ([buttonTitle length])
        {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            UIImage *buttonBackgroundImage = [[UIImage imageNamed:[current valueForKey:@"buttonBackgroundImageName"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
            
            if (!buttonBackgroundImage) {
                buttonBackgroundImage = [[UIImage imageNamed:[current valueForKey:@"NotificationButtonBackground"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
            }
            
            [self.button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
            [self.button setTitle:self.buttonTitle forState:UIControlStateNormal];
            
            UIColor *buttonTitleShadowColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleShadowColor"] alpha:1.0];
            if (!buttonTitleShadowColor) {
                buttonTitleShadowColor = self.titleLabel.shadowColor;
            }
            
            [self.button setTitleShadowColor:buttonTitleShadowColor forState:UIControlStateNormal];
            
            UIColor *buttonTitleTextColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleTextColor"] alpha:1.0];
            if (!buttonTitleTextColor) {
                buttonTitleTextColor = fontColor;
            }
            
            [self.button setTitleColor:buttonTitleTextColor forState:UIControlStateNormal];
            self.button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
            self.button.titleLabel.shadowOffset = CGSizeMake([[current valueForKey:@"buttonTitleShadowOffsetX"] floatValue],
                                                             [[current valueForKey:@"buttonTitleShadowOffsetY"] floatValue]);
            [self.button addTarget:self
                            action:@selector(buttonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            self.button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
            [self.button sizeToFit];
            self.button.frame = CGRectMake(screenWidth - TSMessageViewPadding - self.button.frame.size.width,
                                           0.0,
                                           self.button.frame.size.width,
                                           31.0);
            
            [self addSubview:self.button];
            
            self.textSpaceRight = self.button.frame.size.width + TSMessageViewPadding;
        }
        
        // Add a border on the bottom (or on the top, depending on the view's postion)
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                               0.0, // will be set later
                                                               screenWidth,
                                                               [[current valueForKey:@"borderHeight"] floatValue])];
        self.borderView.backgroundColor = [UIColor colorWithHexString:[current valueForKey:@"borderColor"]
                                                           alpha:1.0];
        self.borderView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        [self addSubview:self.borderView];
        
        
        CGFloat actualHeight = [self updateHeightOfMessageView]; // this call also takes care of positioning the labels
        CGFloat topPosition = -actualHeight;
        
        if (self.messagePosition == TSMessageNotificationPositionBottom)
        {
            topPosition = self.viewController.view.frame.size.height;
        }
        
        self.frame = CGRectMake(0.0, topPosition, screenWidth, actualHeight);
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        
        UISwipeGestureRecognizer *gestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(fadeMeOut)];
        [gestureRec setDirection:(self.messagePosition == TSMessageNotificationPositionTop ?
                                  UISwipeGestureRecognizerDirectionUp :
                                  UISwipeGestureRecognizerDirectionDown)];
        [self addGestureRecognizer:gestureRec];
        
        UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(fadeMeOut)];
        [self addGestureRecognizer:tapRec];
    }
    return self;
}


- (CGFloat)updateHeightOfMessageView
{
    CGFloat currentHeight;
    CGFloat screenWidth = self.viewController.view.frame.size.width;
    
    
    self.titleLabel.frame = CGRectMake(self.textSpaceLeft,
                                       TSMessageViewPadding,
                                       screenWidth - TSMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                       0.0);
    [self.titleLabel sizeToFit];
    
    if ([self.content length])
    {
        self.contentLabel.frame = CGRectMake(self.textSpaceLeft,
                                             self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5.0,
                                             screenWidth - TSMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                             0.0);
        [self.contentLabel sizeToFit];
        
        currentHeight = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    }
    else
    {
        // only the title was set
        currentHeight = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    }
    
    currentHeight += TSMessageViewPadding;
    
    if (self.iconImageView)
    {
        // Check if that makes the popup larger (height)
        if (self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + TSMessageViewPadding > currentHeight)
        {
            currentHeight = self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + TSMessageViewPadding;
            if (![self.content length])
                self.titleLabel.center = CGPointMake([self.titleLabel center].x, round(currentHeight / 2.0));
        }
        else
        {
            // z-align
            self.iconImageView.center = CGPointMake([self.iconImageView center].x,
                                                    round(currentHeight / 2.0));
        }
    }
    
    // z-align button
    self.button.center = CGPointMake([self.button center].x,
                                            round(currentHeight / 2.0));
    
    if (self.messagePosition == TSMessageNotificationPositionTop)
    {
        // Correct the border position
        CGRect borderFrame = self.borderView.frame;
        borderFrame.origin.y = currentHeight;
        self.borderView.frame = borderFrame;
    }
    
    currentHeight += self.borderView.frame.size.height;
    
    self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, currentHeight);
    
    
    if (self.button)
    {
        self.button.frame = CGRectMake(self.frame.size.width - self.textSpaceRight,
                                       round((self.frame.size.height / 2.0) - self.button.frame.size.height / 2.0),
                                       self.button.frame.size.width,
                                       self.button.frame.size.height);
    }
    
    
    self.backgroundImageView.frame = CGRectMake(self.backgroundImageView.frame.origin.x,
                                                self.backgroundImageView.frame.origin.y,
                                                screenWidth,
                                                currentHeight);
    
    return currentHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateHeightOfMessageView];
}

- (void)fadeMeOut
{
    // user tapped on the message
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (self.callback)
        {
            self.callback();
        }
        
        [[TSMessage sharedMessage] performSelector:@selector(fadeOutNotification:)
                                        withObject:self];
    });
}



+ (void) setDefaultValuesForType:(TSMessageNotificationType)notificationType withDictionary:(NSDictionary*)defaultDictionary
{

    switch (notificationType)
    {
        case TSMessageNotificationTypeMessage:
        {
            messageCustomDesign = defaultDictionary;
            break;
        }
        case TSMessageNotificationTypeError:
        {
            errorCustomDesign = defaultDictionary;
            break;
        }
        case TSMessageNotificationTypeSuccess:
        {
            successCustomDesign = defaultDictionary;
            break;
        }
        case TSMessageNotificationTypeWarning:
        {
            warningCustomDesign = defaultDictionary;
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIButton target

- (void)buttonTapped:(id) sender
{
    if (self.buttonCallback) {
        self.buttonCallback();
    }
    
    [self fadeMeOut];
}

@end
