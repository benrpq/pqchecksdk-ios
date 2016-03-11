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

#import <Foundation/Foundation.h>

@class User;

/**
 *  The `UserManager` class handles the users of this sample app. Each user is assigned an identifier. Before a user can use the sample app, he/she needs to go through an enrolment process. Once enrolled, he/she will be added into the set of enrolled users and will then be able to perform basic functionality as implemented in `BankClientManager` class.
 *
 *  While there can be several enrolled users in the sample app, there can only be one active user at a time.
 */
@interface UserManager : NSObject

/**
 *  The active user object
 */
@property (nonatomic, strong) User *activeUser;

/**
 *  Returns the shared user manager object.
 *
 *  @return The default `UserManager` object
 */
+ (UserManager *)defaultManager;

/**
 *  Adds a user to the set of enrolled users.
 *
 *  @param user The user object to be added
 */
- (void)addEnrolledUser:(User *)user;

/**
 *  Deletes an enrolled user
 *
 *  @param user The user object to be deleted
 */
- (void)deleteEnrolledUser:(User *)user;

/**
 *  Returns the set of enrolled users.
 *
 *  @return The set of enrolled users.
 */
- (NSSet *)enrolledUsers;

/**
 *  Returns whether or not the user has been enrolled.
 *
 *  @param user The user object
 *
 *  @return Return YES if the user is already enrolled, NO otherwise.
 */
- (BOOL)isUserEnrolled:(User *)user;

/**
 *  Triggers an update operation on UserManager object. This includes reflecting any changes on the name of an active user to the list of enrolled users.
 */
- (void)update;

@end
