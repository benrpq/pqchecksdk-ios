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

@interface UIColor (Additions)

/**
 * Given a UIColor instance, returns a lighter-coloured version of the instance
 */
- (UIColor *)lighterColor;

/**
 * Given a UIColor instance, returns a darker-coloured version of the instance
 */
- (UIColor *)darkerColor;

/**
 *  Instantiates a new colour from the supplied `hexString`.
 *
 *  @param hexString The colour representing in the format of
 *                   #rrggbb where rr, gg and bb are the red,
 *                   gree and blue colour components respectively.
 *
 *  @return UIColor object with the specified colour
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
