//
//  User.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 04/03/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

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
