//
//  Enrolment.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "Enrolment.h"

@implementation Enrolment

- (id)initWithUserIdentifier:(NSString *)userIdentifier reference:(NSString *)reference transcript:(NSString *)transcript
{
    self = [super init];
    if (self)
    {
        _userIdentifier = userIdentifier;
        _reference = reference;
        _transcript = transcript;
    }
    return self;
}

+ (NSDictionary *)mapping
{
    return @{@"userIdentifier": @"userIdentifier",
             @"reference": @"reference",
             @"transcript": @"transcript"};
}

@end
