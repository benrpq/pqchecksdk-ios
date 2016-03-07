/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
    // Response to an upload attempt
    else if ([request.HTTPMethod isEqualToString:@"POST"] &&
             [[request.URL path] isEqualToString:@"/authorisation/bcd767ff-141f-41b0-b9f4-302f7647eba1/attempt"])
    {
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        NSString *resource = [bundle pathForResource:@"upload-attempt" ofType:@"json"];
        
        return [[NSData alloc] initWithContentsOfFile:resource];
    }
    
    return nil;
}

@end
