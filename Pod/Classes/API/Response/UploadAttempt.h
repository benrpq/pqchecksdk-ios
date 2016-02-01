//
//  UploadAttempt.h
//  PQCheckSDK
//
//  Created by CJ on 24/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadAttempt : NSObject

@property (nonatomic, assign) NSUInteger number;
@property (nonatomic, copy)   NSString *status;
@property (nonatomic, copy)   NSString *nextDigest;

+ (NSDictionary *)mapping;

@end
