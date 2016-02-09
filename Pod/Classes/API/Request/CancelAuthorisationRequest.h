//
//  CancelAuthorisationRequest.h
//  PQCheckSDK
//
//  Created by CJ on 23/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorisationStatus.h"

@interface CancelAuthorisationRequest : NSObject

@property (nonatomic, copy, readonly)   NSString *status;

@property (nonatomic, assign, readonly) PQCheckAuthorisationStatus authorisationStatus;

+ (NSDictionary *)mapping;

@end
