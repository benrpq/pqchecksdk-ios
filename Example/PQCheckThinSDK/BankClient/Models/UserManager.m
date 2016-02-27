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
    NSMutableSet *_enroledSet;
}
@end

static NSString *kPQCheckEnroledUserIdentifiers = @"EnroledUserIdentifiers";
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

- (BOOL)isUserEnroled:(NSString *)userIdentifier
{
    return  [_enroledSet containsObject:userIdentifier];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Load a set of enroled users
        _enroledSet = [[NSMutableSet alloc] init];
        NSArray *identifiers = [[NSUserDefaults standardUserDefaults] objectForKey:kPQCheckEnroledUserIdentifiers];
        if (identifiers)
        {
            _enroledSet = [[NSMutableSet alloc] initWithArray:identifiers];
        }
        
        // Who is the currently enroled user?
        _currentUserIdentifer = [[NSUserDefaults standardUserDefaults] objectForKey:kPQCheckCurrentUserIdentifer];
    }
    return self;
}

- (void)addEnroledUser:(NSString *)userIdentifier
{
    [_enroledSet addObject:userIdentifier];
    
    NSArray *array = [_enroledSet allObjects];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kPQCheckEnroledUserIdentifiers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSSet *)enroledUsers
{
    return _enroledSet;
}

- (void)setCurrentUserIdentifer:(NSString *)currentUserIdentifer
{
    _currentUserIdentifer = currentUserIdentifer;
    
    [[NSUserDefaults standardUserDefaults] setObject:_currentUserIdentifer forKey:kPQCheckCurrentUserIdentifer];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
