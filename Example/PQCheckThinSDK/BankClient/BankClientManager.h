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

@class Enrolment;
@class Authorisation;
@class Payment;

/**
 *  `BankClientManager` is a class that wraps the functionality of a very simplistic bank. Only three functions are available, they are:
 *
 *  - Enrol a user
 *  - Get accounts and payments
 *  - Make a payment
 *
 *  Each of the above functionality requires some API calls, which are neatly wrapped in `BankClientManager` class.
 */
@interface BankClientManager : NSObject

/**
 *  Returns the shared bank client manager object.
 *
 *  @return The default `BankClientManager` object
 */
+ (BankClientManager *)defaultManager;

/**
 *  Set the base URL of the bank application server.
 *  
 *  If a base URL is not set, this default value will be used: `bank-of-jorge.eu-west-1.elasticbeanstalk.com`.
 *
 *  @param baseURL NSURL object representing the base URL
 */
- (void)setBaseURL:(NSURL *)baseURL;

/**
 *  Sends a request to the bank application server that a user identifed by `userUUID` needs to be enrolled.
 *
 *  @param userUUID   The identifier of the user to be enrolled.
 *  @param completion A block object to be executed when the enrolment request is completed. This block has no return value and takes two arguments: an instance of `Enrolment` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `Enrolment` object is `nil`. On the other hand, if it is successful, `NSError` is `nil` and `Enrolment` object, which contains `transcript` and `uri`, should be passed to PQCheck SDK, which in turn will request a user to perform a selfie reading `transcript` and submit the resulting selfie video to `uri`.
 */
- (void)enrolUserWithUUID:(NSString *)userUUID
               completion:(void (^)(Enrolment *enrolment, NSError *error))completion;

/**
 *  Sends a request to the bank application server to return a list of accounts, which contains a set of payments, for a user identified by `userUUUID`.
 *
 *  @param userUUID   The identifier of the user
 *  @param completion A block object to be executed when the enrolment request is completed. This block has no return value and takes two arguments: an array of account collection representations and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and the array is `nil` or empty. On the other hand, if it is successful, `NSError` object is `nil` and the array contains a set of accounts, each of which contains a set of payments.
 *
 * @see AccountCollection class
 */
- (void)getAccountsWithUserUUID:(NSString *)userUUID
                     completion:(void (^)(NSArray *accounts, NSError *error))completion;

/**
 *  Sends a request to the bank application server to approve a payment identified by `paymentUUID` of a user identified by `userUUID`.
 *
 *  @param paymentUUID The identifier of the payment
 *  @param userUUID    The identifier of the user
 *  @param completion  A block object to be executed when the payment approval request is completed. This block has no return value and takes two arguments: an instance of `Payment` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `Payment` object is `nil`. On the other hand, if it is successful, `NSError` object is `nil` and `Payment` object is not `nil` which should then be passed to `viewAuthorisationForPayment:completion:` method.
 *
 *  @see -viewAuthorisationForPayment:completion:
 */
- (void)approvePaymentWithUUID:(NSString *)paymentUUID
                      userUUID:(NSString *)userUUID
                    completion:(void (^)(Payment *payment, NSError *))completion;

/**
 *  Given a payment representation `Payment`, sends a request to PQCheck server to view an authorisation.
 *
 *  The paymenet representation can be obtained from `approvePaymentWithUUID:userUUID:completion:` method.
 *
 *  @param payment    The payment representation
 *  @param completion A block object to be executed when the viewing request is completed. This block has no return value and takes two arguments: an instance of `Authorisation` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `Authorisation` object is `nil`. On the other hand, if it is successful, `NSError` object is `nil` and `Authorisation` object, which contains `digest` and `upload-attempt` amongst other information, should then be passed to PQCheck SDK, which in turn should request a user to perform a selfie reading `digest` and submit the resulting selfie video to `upload-attempt`.
 * 
 *  @see -approvePaymentWithUUID:userUUID:completion:
 */
- (void)viewAuthorisationForPayment:(Payment *)payment
                         completion:(void (^)(Authorisation *authorisation, NSError *error))completion;

@end
