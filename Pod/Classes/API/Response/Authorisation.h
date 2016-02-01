//
//  Authorisation.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Links.h"

@interface Authorisation : NSObject

@property (nonatomic, copy)   NSString *uuid;
@property (nonatomic, copy)   NSString *status;
@property (nonatomic, copy)   NSString *digest;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval expiryTime;
@property (nonatomic, strong) NSArray *attempts;
@property (nonatomic, strong) Links *links;

+ (NSDictionary *)mapping;

@end
