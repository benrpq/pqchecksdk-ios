//
//  APIManager.h
//  PQCheckSDK
//
//  Created by CJ on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef THINSDK
#import "APIKey.h"
#endif
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

#ifndef THINSDK
- (void)createAPIKeyWithCredential:(NSURLCredential *)credential
                         namespace:(NSString *)apiNamespace
                        completion:(void (^)(APIKey *apiKey, NSError *error))completionBlock;

- (void)createAuthorisationWithCredential:(NSURLCredential *)credential
                           userIdentifier:(NSString *)identifier
                        authorisationHash:(NSString *)authorisationHash
                                  summary:(NSString *)summary
                               completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;
- (void)viewAuthorisationRequestWithCredential:(NSURLCredential *)credential
                                          UUID:(NSString *)uuid
                                    completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;
#else
- (void)viewAuthorisationRequestWithUUID:(NSString *)uuid
                              completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;
#endif

#ifndef THINSDK
- (void)cancelAuthorisationRequestWithUUID:(NSString *)uuid
                                completion:(void (^)(NSError *error))completionBlock;
#endif

- (void)uploadAttemptWithAuthorisation:(Authorisation *)authorisation
                              mediaURL:(NSURL *)mediaURL
                            completion:(void (^)(UploadAttempt *uploadAttempt, NSError *error))completionBlock;

#ifndef THINSDK
- (void)enrolUserWithCredential:(NSURLCredential *)credential
                 userIdentifier:(NSString *)identifier
                      reference:(NSString *)reference
                     transcript:(NSString *)transcript
                       mediaURL:(NSURL *)mediaURL
                     completion:(void (^)(NSError *error))completionBlock;
#endif

@end
