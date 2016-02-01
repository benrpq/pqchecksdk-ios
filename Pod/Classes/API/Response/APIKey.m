//
//  APIKeyResponse.m
//  PQCheckSDK
//
//  Created by CJ on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "APIKey.h"

@implementation APIKey

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict objectForKey:@"uuid"])
        {
            self.uuid = [dict objectForKey:@"uuid"];
        }
        if ([dict objectForKey:@"secret"])
        {
            self.secret = [dict objectForKey:@"secret"];
        }
        if ([dict objectForKey:@"namespace"])
        {
            self.apiNamespace = [dict objectForKey:@"namespace"];
        }
    }
    return self;
}

- (NSData *)data
{
    NSDictionary *dict = @{@"uuid": self.uuid,
                           @"secret": self.secret,
                           @"namespace": self.apiNamespace
                           };
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

- (NSString *)description
{
    NSDictionary *dict = @{@"uuid" : self.uuid,
                           @"secret": self.secret,
                           @"namespace": self.apiNamespace
                           };
    return [dict description];
}

+ (NSDictionary *)mapping
{
    return @{@"uuid": @"uuid",
             @"secret": @"secret",
             @"namespace": @"apiNamespace"};
}

@end
