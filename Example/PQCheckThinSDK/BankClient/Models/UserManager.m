//
//  UserManager.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 26/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import "UserManager.h"

@interface UserManager ()
{
    NSMutableSet *_enrolledSet;
}
@end

static NSString *kPQCheckEnrolledUserIdentifiers = @"EnrolledUserIdentifiers";
static NSString *kPQCheckCurrentUserIdentifer = @"CurrentUserIdentifer";

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

- (BOOL)isUserEnrolled:(NSString *)userIdentifier
{
    return  [_enrolledSet containsObject:userIdentifier];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Load a set of enrolled users
        _enrolledSet = [[NSMutableSet alloc] init];
        NSArray *identifiers = [[NSUserDefaults standardUserDefaults] objectForKey:kPQCheckEnrolledUserIdentifiers];
        if (identifiers)
        {
            _enrolledSet = [[NSMutableSet alloc] initWithArray:identifiers];
        }
        
        // Who is the currently enrolled user?
        _currentUserIdentifer = [[NSUserDefaults standardUserDefaults] objectForKey:kPQCheckCurrentUserIdentifer];
    }
    return self;
}

- (void)addEnrolledUser:(NSString *)userIdentifier
{
    [_enrolledSet addObject:userIdentifier];
    
    NSArray *array = [_enrolledSet allObjects];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kPQCheckEnrolledUserIdentifiers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSSet *)enrolledUsers
{
    return _enrolledSet;
}

- (void)setCurrentUserIdentifer:(NSString *)currentUserIdentifer
{
    _currentUserIdentifer = currentUserIdentifer;
    
    [[NSUserDefaults standardUserDefaults] setObject:_currentUserIdentifer forKey:kPQCheckCurrentUserIdentifer];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
