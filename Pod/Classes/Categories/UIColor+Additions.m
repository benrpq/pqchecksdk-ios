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

#import "UIColor+Additions.h"
#import "NSString+Utils.h"

@implementation UIColor (Additions)

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    if ([NSString isStringNilEmptyOrNewLine:hexString])
    {
        return nil;
    }
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:[hexString uppercaseString]];
    NSCharacterSet *nonHexCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
    [scanner setCharactersToBeSkipped:nonHexCharacters];
    
    BOOL validScan = [scanner scanHexInt:&rgbValue];
    return validScan ? [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                                       green:((rgbValue & 0xFF00) >> 8)/255.0
                                        blue:(rgbValue & 0xFF)/255.0 alpha:1.0] : nil;
}

@end
