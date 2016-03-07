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
