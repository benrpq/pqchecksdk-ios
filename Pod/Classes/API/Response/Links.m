//
//  Links.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "Links.h"

@implementation Links

- (NSString *)description
{
    NSDictionary *dict = @{@"self": self.selfPath,
                           @"upload-attempt": self.uploadAttemptPath
                           };
    return [dict description];
}

+ (NSDictionary *)mapping
{
    return @{@"self": @"selfPath",
             @"upload-attempt": @"uploadAttemptPath"};
}

@end
