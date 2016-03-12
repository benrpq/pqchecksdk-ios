//
//  Attempts.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 29/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class encapsulates an authorisation attempt
 */
@interface Attempts : NSObject

/**
 *  The attempt number
 */
@property (nonatomic, strong) NSNumber *attemptNumber;

/**
 *  The timestamp when the attempt was meade
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 *  The boolean value of the attempt result
 */
@property (nonatomic, assign) BOOL isSuccessful;

/**
 *  The array containing biometric evaluations
 */
@property (nonatomic, strong) NSArray *biometricEvaluations;

+ (NSDictionary *)mapping;

@end
