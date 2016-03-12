//
//  BiometricEvaluation.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Authenticity.h"

/**
 *  `BiometricEvaluations` object encapsulates the evaluation results of a biometric engine
 */
@interface BiometricEvaluations : NSObject

/**
 *  The name of the biometric engine
 */
@property (nonatomic, copy)   NSString *biometric;

/**
 *  The authenticity object
 */
@property (nonatomic, strong) Authenticity *authenticity;

/**
 *  The accuracy of the biometric evaluation
 */
@property (nonatomic, assign) CGFloat accuracy;

/**
 *  The detail of a rejection, if any
 */
@property (nonatomic, copy)   NSString *rejectionDetail;

/**
 *  The log, if any
 */
@property (nonatomic, copy)   NSString *log;

+ (NSDictionary *)mapping;

@end
