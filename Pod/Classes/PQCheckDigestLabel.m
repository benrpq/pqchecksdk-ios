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

#import "PQCheckDigestLabel.h"

static const CGFloat kDefaultFontSize = 64.0f;
static const CGFloat kDefaultLabelHeight = 64.0f;
static const CGFloat kWidthMargin = 20.0f;
static const NSInteger kFontReductionTrialLimit = 10;

@interface PQCheckDigestLabel ()
{
    NSString *_digest;
    NSArray *_labelArray;
    NSInteger _animationIndex;
    BOOL _isAnimating;
}
@end

@implementation PQCheckDigestLabel

- (id)initWithDigest:(NSString *)digest
{
    self = [super init];
    if (self) {
        _digest = digest;
        _animationIndex = 0;
        _isAnimating = NO;
        _labelColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:13.0f/255.0f
                                               green:185.0f/255.0f
                                                blue:78.0f/255.0f
                                               alpha:1.0f];
        self.hidden = YES;
        
        [self configureView];
    }
    return self;
}

- (void)show
{
    self.hidden = NO;
    _isAnimating = YES;
    for (NSInteger index=0; index<[_digest length]; index++)
    {
        UILabel *label = [self viewWithTag:index+1];
        if (label != nil)
        {
            label.layer.opacity = 1.0f;
        }
    }
    _isAnimating = NO;
}

- (void)showAnimatedWithDelayInterval:(NSTimeInterval)interval
{
    self.hidden = NO;
    _isAnimating = YES;
    _animationIndex = 0;
    if (_animationIndex < [_digest length])
    {
        [self animateNextLabelWithDuration:interval];
    }
    else
    {
        _isAnimating = NO;
        
        // Indicate animation has been completed successfully
        // Strictly speaking, this is arguable. We only get to this point because of zero length digest
        if ([self.delegate respondsToSelector:@selector(PQCheckDigestLabel:didFinishAnimationWithSuccess:)])
        {
            [self.delegate PQCheckDigestLabel:self didFinishAnimationWithSuccess:YES];
        }
    }
}

- (BOOL)dismiss
{
    if (_isAnimating)
    {
        return NO;
    }

    for (NSInteger index=0; index<[_digest length]; index++)
    {
        UILabel *label = [self viewWithTag:index+1];
        if (label != nil)
        {
            label.layer.opacity = 0.0f;
        }
    }
    
    self.hidden = YES;

    return YES;
}

- (void)setLabelColor:(UIColor *)labelColor
{
    _labelColor = labelColor;
    
    for (NSInteger index=0; index<[_digest length]; index++)
    {
        UILabel *label = [self viewWithTag:index+1];
        if (label != nil)
        {
            label.textColor = _labelColor;
        }
    }
}

- (void)configureView
{
    if ([_digest length] <= 0)
    {
        return;
    }
    
    for (int i=0; i<[_digest length]; i++)
    {
        UILabel *label = [self createGenericUILabel];
        [label setTag:i+1]; // The tag value must be non-zero
        [label setText:[_digest substringWithRange:NSMakeRange(i, 1)]];
        [self addSubview:label];
    }
    
    [self updateLayout];
}

- (void)updateLayout
{
    CGFloat width = 0.0f;
    CGFloat height = kDefaultLabelHeight;
    CGFloat fontSize = kDefaultFontSize;
    CGSize size = [[UIScreen mainScreen] bounds].size;
    NSInteger trial = 0;
    do
    {
        width = kWidthMargin / 2.0f;
        for (int i=0; i<[_digest length]; i++)
        {
            UILabel *label = [self viewWithTag:i+1];
            [label setFont:[UIFont boldSystemFontOfSize:fontSize]];
            [label sizeToFit];
            
            CGRect frame = [label frame];
            frame.origin.x = width;
            label.frame = frame;
            width += frame.size.width;
            height = frame.size.height;
        }
        ++trial;
        fontSize -= 2.0f;
    }
    while (width + kWidthMargin > size.width &&
           trial < kFontReductionTrialLimit);

    CGRect frame = CGRectMake(0.0, 0.0, width + kWidthMargin, height);
    self.frame = frame;
}

- (UILabel *)createGenericUILabel
{
    CGRect frame = CGRectMake(0.0, 0.0, kDefaultLabelHeight, kDefaultLabelHeight);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont boldSystemFontOfSize:kDefaultFontSize];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.labelColor;
    label.layer.opacity = 0.0f;
    
    return label;
}

- (void)animateNextLabelWithDuration:(NSTimeInterval)duration
{
    UILabel *label = [self viewWithTag:_animationIndex + 1];
    if (label != nil)
    {
        label.layer.opacity = 0.0f;
        [UIView animateWithDuration:duration animations:^{
            label.layer.opacity = 1.0f;
        } completion:^(BOOL finished) {
            if (finished && ++_animationIndex < [_digest length])
            {
                [self animateNextLabelWithDuration:duration];
            }
            else
            {
                _isAnimating = NO;
                
                // Indicate animation has been completed successfully
                if ([self.delegate respondsToSelector:@selector(PQCheckDigestLabel:didFinishAnimationWithSuccess:)])
                {
                    [self.delegate PQCheckDigestLabel:self didFinishAnimationWithSuccess:YES];
                }
            }
        }];
    }
    else
    {
        _isAnimating = NO;
        
        // Indicate animation has been completed, but with error
        if ([self.delegate respondsToSelector:@selector(PQCheckDigestLabel:didFinishAnimationWithSuccess:)])
        {
            [self.delegate PQCheckDigestLabel:self didFinishAnimationWithSuccess:NO];
        }
    }
}

@end
