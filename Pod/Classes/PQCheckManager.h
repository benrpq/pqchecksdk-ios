//
//  PQCheckManager.h
//  Pods
//
//  Created by CJ Tjhai on 01/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "AuthorisationStatus.h"

@class Authorisation;
@protocol PQCheckManagerDelegate;

@interface PQCheckManager : NSObject

@property (nonatomic, weak)   id<PQCheckManagerDelegate> delegate;
@property (nonatomic, assign) BOOL autoAttemptOnFailure;
@property (nonatomic, assign) BOOL shouldPaceUser;

#ifndef THINSDK
- (id)initWithUserIdentifier:(NSString *)userIdentifier;
- (void)setAdminCredential:(NSURLCredential *)adminCredential;
- (void)resetAPIKey;
- (NSString *)currentNamespace;
#else
- (id)initWithAuthorisation:(Authorisation *)authorisation;
#endif

- (void)performAuthorisationWithHash:(NSString *)authorisationHash summary:(NSString *)summary;
- (void)performEnrolmentWithReference:(NSString *)reference transcript:(NSString *)transcript;
@end


@protocol PQCheckManagerDelegate <NSObject>
@optional
- (void)PQCheckManagerDidFinishEnrolment:(PQCheckManager *)manager;
- (void)PQCheckManager:(PQCheckManager *)manager didFinishWithAuthorisationStatus:(PQCheckAuthorisationStatus)status;
- (void)PQCheckManager:(PQCheckManager *)manager didFailWithError:(NSError *)error;
@end