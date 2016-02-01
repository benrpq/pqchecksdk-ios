//
//  APIKeyResponse.h
//  PQCheckSDK
//
//  Created by CJ on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIKey : NSObject

@property (nonatomic, copy) NSString *apiNamespace;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *secret;

- (id)initWithData:(NSData *)data;

- (NSData *)data;

+ (NSDictionary *)mapping;

@end
