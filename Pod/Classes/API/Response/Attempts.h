//
//  Attempts.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 29/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attempts : NSObject

@property (nonatomic, strong) NSNumber *attemptNumber;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) BOOL isSuccessful;
@property (nonatomic, strong) NSArray *biometricEvaluations;

+ (NSDictionary *)mapping;

@end
