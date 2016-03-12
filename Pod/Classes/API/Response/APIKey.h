//
//  APIKeyResponse.h
//  PQCheckSDK
//
//  Created by CJ on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An API key is needed to perform authorised calls to PQCheck backend
 */
@interface APIKey : NSObject

/**
 *  The namespace of an API key
 */
@property (nonatomic, copy) NSString *apiNamespace;

/**
 *  The UUID (username) of an API key
 */
@property (nonatomic, copy) NSString *uuid;

/**
 *  The secret (password) of an API key
 */
@property (nonatomic, copy) NSString *secret;

- (id)initWithData:(NSData *)data;

- (NSData *)data;

+ (NSDictionary *)mapping;

@end
