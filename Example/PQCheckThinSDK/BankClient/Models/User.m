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

#import "User.h"

@implementation User

static NSString *kUserIdentifier = @"UserIdentifier";
static NSString *kUserName = @"Name";

- (id)init
{
    self = [super init];
    if (self) {
        self.identifier = [[[NSUUID UUID] UUIDString] lowercaseString];
        self.name = self.identifier;
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        NSDictionary *userDictionary = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.identifier = [userDictionary objectForKey:kUserIdentifier];
        self.name = [userDictionary objectForKey:kUserName];
    }
    return self;
}

- (NSData *)data
{
    NSDictionary *userDictionary = @{kUserIdentifier: self.identifier,
                                     kUserName: self.name
                                     };
    return [NSKeyedArchiver archivedDataWithRootObject:userDictionary];
}

@end
