//
//  HRef.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "URIPath.h"

@implementation URIPath

- (NSString *)description
{
    return [@{@"href": self.href} description];
}

+ (NSDictionary *)mapping
{
    return @{@"href": @"href"};
}

@end
