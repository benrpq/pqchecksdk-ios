//
//  UserManager.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 26/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The `UserManager` class handles the users of this sample app. Each user is assigned an identifier. Before a user can use the sample app, he/she needs to go through an enrolment process. Once enrolled, he/she will be added into the set of enrolled users and will then be able to perform basic functionality as implemented in `BankClientManager` class.
 *
 *  While there can be several enrolled users in the sample app, there can only be one active user at a time.
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
 *  Adds a user identified by `userIdentifier` to a set of enrolled users.
 *
 *  @param userIdentifier The user identifier
 */
- (void)addEnrolledUser:(NSString *)userIdentifier;

/**
 *  Returns the set of enrolled users.
 *
 *  @return The set of enrolled users.
 */
- (NSSet *)enrolledUsers;

/**
 *  Returns whether or not the user identified by `userIdentifier` has been enrolled.
 *
 *  @param userIdentifier The user identifier
 *
 *  @return Return YES if the user is already enrolled, NO otherwise.
 */
- (BOOL)isUserEnrolled:(NSString *)userIdentifier;

@end
