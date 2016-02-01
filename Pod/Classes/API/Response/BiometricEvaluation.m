//
//  BiometricEvaluation.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "BiometricEvaluation.h"

@implementation BiometricEvaluation

- (id)initWithId:(NSInteger)evaluationId
       biometric:(NSString *)biometric
    authenticity:(CGFloat)authenticity
        accuracy:(CGFloat)accuracy
 rejectionDetail:(NSString *)rejectionDetail
             log:(NSString *)log
{
    self = [super init];
    if (self)
    {
        self.evaluationId = evaluationId;
        self.biometric = biometric;
        self.authenticity = authenticity;
        self.accuracy = accuracy;
        self.rejectionDetail = rejectionDetail;
        self.log = log;
    }
    return self;
}

- (NSString *)description
{
    NSDictionary *dict = @{@"evaluationId": @(self.evaluationId),
                           @"biometric": self.biometric,
                           @"authenticity": @(self.authenticity),
                           @"accuracy": @(self.accuracy),
                           @"rejectionDetail": self.rejectionDetail,
                           @"log": self.log
                           };
    return [dict description];
}

+ (NSDictionary *)mapping
{
    return @{@"evaluationId": @"evaluationId",
             @"biometric": @"biometric",
             @"authenticity": @"authenticity",
             @"accuracy": @"accuracy",
             @"rejectionDetail": @"rejectionDetail",
             @"log": @"log"};
}

@end
