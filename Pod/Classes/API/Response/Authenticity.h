//
//  Authenticity.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 29/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  The class wraps a set of authenticity measures
 */
@interface Authenticity : NSObject

/**
 *  The result of facial biometric evaluation, the value ranges from 0.0 to 1.0
 */
@property (nonatomic, strong) NSNumber *FACE;

+ (NSDictionary *)mapping;

@end
