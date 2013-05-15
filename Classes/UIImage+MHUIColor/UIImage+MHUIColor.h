//
//  UIImage+TMCUIColor.h
//  Pods
//
//  Created by Marcos Hernandez on 5/15/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (MHUIColor)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColorString:(NSString *)colorHexString;

@end
