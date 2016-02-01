//
//  PQCheckFaceShape.m
//  PQCheck Objective-C Sample
//
//  Created by CJ on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "PQCheckFaceShape.h"

static const CGFloat kHorizontalOvalRatio = 0.6f;
static const CGFloat kVerticalOvalRatio = 0.5f;

@implementation PQCheckFaceShape

@synthesize outerFillColor;

- (id)initWithFrame:(CGRect)frame
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:screenFrame];
    if (self)
    {
        self.outerFillColor = [UIColor whiteColor];
        self.outerFillOpacity = 1.0f;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGSize size = rect.size;
    CGFloat ovalWidth = kHorizontalOvalRatio*size.width;
    CGFloat ovalHeight = kVerticalOvalRatio*size.height;
    CGFloat ovalXOffset = (size.width - ovalWidth)/2.0f;
    CGFloat ovalYOffset = (size.height - ovalHeight)/2.0f;
    CGRect ovalFrame = CGRectMake(ovalXOffset, ovalYOffset, ovalWidth, ovalHeight);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:ovalFrame];
    UIColor *fillColor = [self.outerFillColor colorWithAlphaComponent:self.outerFillOpacity];
    [fillColor set];
    UIRectFill(rect);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    [path fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

@end
