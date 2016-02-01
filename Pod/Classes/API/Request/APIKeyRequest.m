//
//  APIKeyRequest.m
//  PQCheckSDK
//
//  Created by CJ on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "APIKeyRequest.h"

@implementation APIKeyRequest

- (id)initWithAPINamespace:(NSString *)apiNamespace
{
    self = [super init];
    if (self)
    {
        self.apiNamespace = apiNamespace;
    }
    return self;
}

+ (NSDictionary *)mapping
{
    return @{@"namespace": @"apiNamespace"};
}

@end
