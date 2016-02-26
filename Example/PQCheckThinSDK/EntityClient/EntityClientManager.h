//
//  EntityClientManager.h
//  Pods
//
//  Created by CJ on 01/02/2016.
//
//

#import <Foundation/Foundation.h>

@class Enrolment;
@class Authorisation;
@class Payment;

@interface EntityClientManager : NSObject

+ (EntityClientManager *)defaultManager;

- (void)setBaseURL:(NSURL *)baseURL;

- (void)setProfile:(NSString *)profile;

- (void)setVersion:(NSNumber *)version;

- (void)enrolUserWithUUID:(NSString *)userUUID
               completion:(void (^)(Enrolment *enrolment, NSError *error))completion;

- (void)getAccountsWithUserUUID:(NSString *)userUUID
                     completion:(void (^)(NSArray *accounts, NSError *error))completion;

- (void)approvePaymentWithUUID:(NSString *)paymentUUID
                      userUUID:(NSString *)userUUID
                    completion:(void (^)(Payment *payment, NSError *))completion;

- (void)viewAuthorisationForPayment:(Payment *)payment
                         completion:(void (^)(Authorisation *authorisation, NSError *error))completion;

@end
