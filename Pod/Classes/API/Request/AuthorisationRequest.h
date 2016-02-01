//
//  AuthorisationRequest.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorisationRequest : NSObject

@property (nonatomic, copy) NSString *userIdentifier;
@property (nonatomic, copy) NSString *authorisationHash;
@property (nonatomic, copy) NSString *summary;

- (id)initWithUserIdentifier:(NSString *)identifier
           authorisationHash:(NSString *)authorisationHash
                     summary:(NSString *)summary;

+ (NSDictionary *)mapping;

@end
