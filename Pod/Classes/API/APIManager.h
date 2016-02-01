//
//  APIManager.h
//  PQCheckSDK
//
//  Created by CJ on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIKey.h"
#import "Authorisation.h"
#import "UploadAttempt.h"

typedef NS_ENUM(NSInteger, PQCheckEndpoint)
{
    kStableEndpoint = 0,
    kUnstableEndpoint,
    kDevelopmentEndpoint,
    kDataCollectionEndpoint
};

@interface APIManager : NSObject

+ (APIManager *)sharedManager;

- (NSString *)currentPQCheckEndpoint;

- (void)setPQCheckEndpoint:(PQCheckEndpoint)endpoint;

- (void)setProfile:(NSString *)profile;

- (void)setVersion:(NSNumber *)version;

- (void)createAPIKeyWithCredential:(NSURLCredential *)credential
                         namespace:(NSString *)apiNamespace
                        completion:(void (^)(APIKey *apiKey, NSError *error))completionBlock;

- (void)createAuthorisationWithCredential:(NSURLCredential *)credential
                           userIdentifier:(NSString *)identifier
                                   digest:(NSString *)digest
                                  summary:(NSString *)summary
                               completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;

- (void)viewAuthorisationRequestWithCredential:(NSURLCredential *)credential
                                          UUID:(NSString *)uuid
                                    completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;

- (void)cancelAuthorisationRequestWithUUID:(NSString *)uuid
                                completion:(void (^)(NSError *error))completionBlock;

- (void)uploadAttemptWithAuthorisation:(Authorisation *)authorisation
                              mediaURL:(NSURL *)mediaURL
                            completion:(void (^)(UploadAttempt *uploadAttempt, NSError *error))completionBlock;

- (void)enrolUserWithIdentifier:(NSString *)userIdentifier
                      reference:(NSString *)reference
                     transcript:(NSString *)transcript
                       mediaURL:(NSURL *)movieURL
                     completion:(void (^)(NSURL *uploadURI, NSError *error))completionBlock;

@end
