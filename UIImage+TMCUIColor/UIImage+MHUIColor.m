//
//  UIImage+TMCUIColor.m
//  Pods
//
//  Created by Marcos Hernandez on 5/15/13.
//
//

#import "UIImage+MHUIColor.h"
#import "UIColor+MLColorAdditions.h"

@implementation UIImage (MHUIColor)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColorString:(NSString *)colorHexString{
    
    UIColor *backgroundColor = [UIColor colorWithHexString:colorHexString alpha:1.0];
    return [UIImage imageWithColor:backgroundColor];
}


@end
