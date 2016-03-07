/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)rectangularImageWithSize:(CGSize)size
                            fillColor:(UIColor *)fillColor
                          borderColor:(UIColor *)borderColor
                       andBorderWidth:(CGFloat)borderWidth
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGRect rect = CGRectMake(1.0f, 1.0f, size.width-2.0, size.height-2.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    if (borderWidth > 0.0005)
    {
        [borderColor setStroke];
        [path setLineWidth:borderWidth];
        [path stroke];
    }
    [fillColor setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)circularImageWithRadius:(CGFloat)radius
                           fillColor:(UIColor *)fillColor
                         borderColor:(UIColor *)borderColor
                      andBorderWidth:(CGFloat)borderWidth
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0*radius, 2.0*radius), NO, 0.0f);
    CGRect rect = CGRectMake(1.0f, 1.0f, 2.0f*(radius-1.0), 2.0f*(radius-1.0));
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    if (borderWidth > 0.0005)
    {
        [borderColor setStroke];
        [path setLineWidth:borderWidth];
        [path stroke];
    }
    [fillColor setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    UIImage *imageMask = [UIImage imageWithCGImage:masked];
    CFRelease(masked);
    CFRelease(mask);
    
    return imageMask;
    
}

- (UIImage *)roundedCornerImage
{
    // In order to return a circular image from a squared image,
    // we need to create a mask, which is a squared image with
    // white background and a black circle to denote the area
    // at which we want the image to be drawn
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [[UIColor whiteColor] setFill];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRect:rect] fill];
    [[UIColor blackColor] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:rect] fill];
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage maskImage:self withMask:maskImage];
}

- (UIImage *)roundedCornerImageWithBorderWidth:(CGFloat)borderWidth
                                andBorderColor:(UIColor *)borderColor
{
    UIImage *image = [self roundedCornerImage];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointZero];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [borderColor setStroke];
    CGRect circleRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    circleRect = CGRectInset(circleRect, borderWidth, borderWidth);
    CGContextSetLineWidth(context, borderWidth);
    CGContextStrokeEllipseInRect(context, circleRect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
