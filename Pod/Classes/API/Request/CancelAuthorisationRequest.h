//
//  CancelAuthorisationRequest.h
//  PQCheckSDK
//
//  Created by CJ on 23/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CancelAuthorisationRequest : NSObject

@property (nonatomic, copy) NSString *status;

+ (NSDictionary *)mapping;

@end
