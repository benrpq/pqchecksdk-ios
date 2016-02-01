//
//  BiometricEvaluation.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BiometricEvaluation : NSObject

@property (nonatomic, assign) NSInteger evaluationId;
@property (nonatomic, copy)   NSString *biometric;
@property (nonatomic, assign) CGFloat authenticity;
@property (nonatomic, assign) CGFloat accuracy;
@property (nonatomic, copy)   NSString *rejectionDetail;
@property (nonatomic, copy)   NSString *log;

- (id)initWithId:(NSInteger)evaluationId
       biometric:(NSString *)biometric
    authenticity:(CGFloat)authenticity
        accuracy:(CGFloat)accuracy
 rejectionDetail:(NSString *)rejectionDetail
             log:(NSString *)log;

+ (NSDictionary *)mapping;

@end
