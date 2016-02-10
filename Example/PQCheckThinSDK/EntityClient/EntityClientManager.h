//
//  EntityClientManager.h
//  Pods
//
//  Created by CJ on 01/02/2016.
//
//

#import <Foundation/Foundation.h>

@class Authorisation;

@interface EntityClientManager : NSObject

+ (EntityClientManager *)defaultManager;

- (void)setBaseURL:(NSURL *)baseURL;

- (void)setProfile:(NSString *)profile;

- (void)setVersion:(NSNumber *)version;

- (void)getAccountsWithUserUUID:(NSString *)userUUID
                     completion:(void (^)(NSArray *accounts, NSError *error))completion;

- (void)approvePaymentWithUUID:(NSString *)paymentUUID
                      userUUID:(NSString *)userUUID
                    completion:(void (^)(Authorisation *authorisation, NSError *error))completion;

@end
