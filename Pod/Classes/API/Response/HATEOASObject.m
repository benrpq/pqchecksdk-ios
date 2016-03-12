//
//  HATEOASObject
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "HATEOASObject.h"

@implementation HATEOASObject

- (NSString *)description
{
    return [@{@"href": self.href} description];
}

+ (NSDictionary *)mapping
{
    return @{@"href": @"href"};
}

@end
