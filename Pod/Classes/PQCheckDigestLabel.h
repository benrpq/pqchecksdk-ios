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