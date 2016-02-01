//
//  UIImage+Additions.h
//  PQCheck Objective-C Sample
//
//  Created by CJ on 19/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+ (UIImage *)rectangularImageWithSize:(CGSize)size
                            fillColor:(UIColor *)fillColor
                          borderColor:(UIColor *)borderColor
                       andBorderWidth:(CGFloat)borderWidth;
+ (UIImage *)circularImageWithRadius:(CGFloat)radius
                           fillColor:(UIColor *)fillColor
                         borderColor:(UIColor *)borderColor
                      andBorderWidth:(CGFloat)borderWidth;
+ (UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
- (UIImage *)roundedCornerImage;
- (UIImage *)roundedCornerImageWithBorderWidth:(CGFloat)borderWidth
                                andBorderColor:(UIColor *)borderColor;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
