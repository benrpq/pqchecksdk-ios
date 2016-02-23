//
//  Enrolment.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Enrolment : NSObject

@property (nonatomic, copy) NSString *userIdentifier;
@property (nonatomic, copy) NSString *reference;
@property (nonatomic, copy) NSString *transcript;

- (id)initWithUserIdentifier:(NSString *)userIdentifier
                   reference:(NSString *)reference
                  transcript:(NSString *)transcript;

+ (NSDictionary *)mapping;

@end
