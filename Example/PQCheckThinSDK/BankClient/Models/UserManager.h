//
//  UserManager.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 26/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The `UserManager` class handles the users of this sample app. Each user is assigned an identifier. Before a user can use the sample app, he/she needs to go through an enrolment process. Once enroled, he/she will be added into the set of enroled users and will then be able to perform basic functionality as implemented in `BankClientManager` class.
 *
 *  While there can be more than one enroled users in the sample app, there can only be one active user.
 */
@interface UserManager : NSObject

/**
 *  The identifier of the current active user.
 */
@property (nonatomic, copy) NSString* currentUserIdentifer;

/**
 *  Returns the shared user manager object.
 *
 *  @return The default `UserManager` object
 */
+ (UserManager *)defaultManager;

/**
 *  Adds a user identified by `userIdentifier` to a set of enroled users.
 *
 *  @param userIdentifier The user identifier
 */
- (void)addEnroledUser:(NSString *)userIdentifier;

/**
 *  Returns the set of enroled users.
 *
 *  @return The set of enroled users.
 */
- (NSSet *)enroledUsers;

/**
 *  Returns whether or not the user identified by `userIdentifier` has been enroled.
 *
 *  @param userIdentifier The user identifier
 *
 *  @return Return YES if the user is already enroled, NO otherwise.
 */
- (BOOL)isUserEnroled:(NSString *)userIdentifier;

@end
