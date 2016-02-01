//
//  PQCheckManager.h
//  Pods
//
//  Created by CJ Tjhai on 01/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "AuthorisationStatus.h"

@protocol PQCheckManagerDelegate;

@interface PQCheckManager : NSObject

@property (nonatomic, weak)   id<PQCheckManagerDelegate> delegate;
@property (nonatomic, assign) BOOL autoAttemptOnFailure;
@property (nonatomic, assign) BOOL shouldPaceUser;

- (id)initWithUserIdentifier:(NSString *)userIdentifier
                      digest:(NSString *)digest
                     summary:(NSString *)summary;

- (void)performAuthentication;
@end


@protocol PQCheckManagerDelegate <NSObject>
@optional
- (void)PQCheckManager:(PQCheckManager *)manager didFinishWithAuthorisationStatus:(PQCheckAuthorisationStatus)status;
- (void)PQCheckManager:(PQCheckManager *)manager didFailWithError:(NSError *)error;
@end