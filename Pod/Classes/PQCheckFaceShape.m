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
