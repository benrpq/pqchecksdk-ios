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

#import "UserManager.h"
#import "User.h"

@interface UserManager ()
{
    NSMutableSet *_enrolledSet;
}
@end

static NSString *kPQCheckEnrolledUsers = @"EnrolledUsers";
static NSString *kPQCheckActiveUser = @"ActiveUser";

@implementation UserManager

+ (UserManager *)defaultManager
{
    static UserManager *_userManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userManager = [[UserManager alloc] init];
    });
    return _userManager;
}

- (BOOL)isUserEnrolled:(User *)user
{
    NSSet *set = [_enrolledSet objectsPassingTest:^BOOL(id  _Nonnull obj, BOOL * _Nonnull stop) {
        User *aUser = (User *)obj;
        return ([aUser.identifier caseInsensitiveCompare:user.identifier] == NSOrderedSame);
    }];
    return (set && [set count] > 0);
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Load a set of enrolled users
        _enrolledSet = [[NSMutableSet alloc] init];
        NSArray *userArray = [[NSUserDefaults standardUserDefaults] objectForKey:kPQCheckEnrolledUsers];
        if (userArray)
        {
            for (NSData *data in userArray)
            {
                User *aUser = [[User alloc] initWithData:data];
                [_enrolledSet addObject:aUser];
            }
        }
        
        // Who is the currently enrolled user?
        _activeUser = nil;
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kPQCheckActiveUser];
        if (data)
        {
            _activeUser = [[User alloc] initWithData:data];
        }
    }
    return self;
}

- (void)addEnrolledUser:(User *)user
{
    [_enrolledSet addObject:user];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (User *aUser in [_enrolledSet allObjects])
    {
        [array addObject:[aUser data]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kPQCheckEnrolledUsers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteEnrolledUser:(User *)user
{
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for (User *aUser in [_enrolledSet allObjects])
    {
        if ([aUser.identifier caseInsensitiveCompare:user.identifier] != NSOrderedSame)
        {
            [set addObject:aUser];
        }
    }
    _enrolledSet = [[NSMutableSet alloc] initWithSet:set];
    
    // Are we deleting an active user?
    if ([_activeUser.identifier caseInsensitiveCompare:user.identifier] == NSOrderedSame)
    {
        // Pick an arbitrary user as the new active user
        User *aUser = [[_enrolledSet allObjects] firstObject];
        [self setActiveUser:aUser];
    }
}

- (NSSet *)enrolledUsers
{
    return _enrolledSet;
}

- (void)setActiveUser:(User *)activeUser
{
    _activeUser = activeUser;
    
    if (activeUser == nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPQCheckActiveUser];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[activeUser data] forKey:kPQCheckActiveUser];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)update
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (User *aUser in [_enrolledSet allObjects])
    {
        if ([aUser.identifier caseInsensitiveCompare:_activeUser.identifier] == NSOrderedSame)
        {
            if (_activeUser.name && [_activeUser.name length] > 0 &&
                [aUser.name isEqualToString:_activeUser.name] == NO)
            {
                aUser.name = _activeUser.name;
            }
        }
        [array addObject:[aUser data]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kPQCheckEnrolledUsers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
