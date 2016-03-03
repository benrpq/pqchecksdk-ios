//
//  MockedPQCheckServer.m
//  PQCheckSDK
//
//  Created by CJ on 02/03/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import "MockedPQCheckServer.h"

@implementation MockedPQCheckServer

- (NSData *)responseDataForClient:(id<NSURLProtocolClient>)client request:(NSURLRequest *)request
{
    // Authorisation representation
    if ([request.HTTPMethod isEqualToString:@"GET"] &&
        [[request.URL path] isEqualToString:@"/authorisation/bcd767ff-141f-41b0-b9f4-302f7647eba1"])
    {
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        NSString *resource = [bundle pathForResource:@"authorisation" ofType:@"json"];
        
        return [[NSData alloc] initWithContentsOfFile:resource];
    }
    
    return nil;
}

@end
