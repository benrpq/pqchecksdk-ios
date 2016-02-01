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

@interface BiometricEvaluations : NSObject

@property (nonatomic, copy)   NSString *biometric;
@property (nonatomic, strong) Authenticity *authenticity;
@property (nonatomic, assign) CGFloat accuracy;
@property (nonatomic, copy)   NSString *rejectionDetail;
@property (nonatomic, copy)   NSString *log;

+ (NSDictionary *)mapping;

@end
