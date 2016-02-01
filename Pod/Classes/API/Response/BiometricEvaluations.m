//
//  BiometricEvaluation.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "BiometricEvaluations.h"

@implementation BiometricEvaluations

+ (NSDictionary *)mapping
{
    return @{@"biometric": @"biometric",
             @"accuracy": @"accuracy",
             @"rejectionDetail": @"rejectionDetail",
             @"log": @"log"};
}

@end
