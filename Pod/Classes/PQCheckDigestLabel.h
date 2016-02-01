//
//  PQCheckDigestLabel.h
//  PQCheck Objective-C Sample
//
//  Created by CJ on 20/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PQCheckDigestLabelDelegate;

@interface PQCheckDigestLabel : UIView

@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, weak) id<PQCheckDigestLabelDelegate> delegate;

- (id)initWithDigest:(NSString *)digest;
- (void)show;
- (void)showAnimatedWithDelayInterval:(NSTimeInterval)interval;
- (BOOL)dismiss;

@end


@protocol PQCheckDigestLabelDelegate <NSObject>

@optional
- (void)         PQCheckDigestLabel:(PQCheckDigestLabel *)digestLabel
      didFinishAnimationWithSuccess:(BOOL)success;

@end