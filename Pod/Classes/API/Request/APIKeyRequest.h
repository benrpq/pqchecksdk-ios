//
//  APIKeyRequest.h
//  PQCheckSDK
//
//  Created by CJ on 21/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIKeyRequest : NSObject

@property (nonatomic, copy) NSString *apiNamespace;

- (id)initWithAPINamespace:(NSString *)apiNamespace;

+ (NSDictionary *)mapping;

@end
