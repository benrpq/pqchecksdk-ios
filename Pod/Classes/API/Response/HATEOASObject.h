//
//  HATEOASObject.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  HATEOAS representation of the URL location of an object.
 */
@interface HATEOASObject : NSObject

/**
 *  The URL value
 */
@property (nonatomic, copy) NSString *href;

+ (NSDictionary *)mapping;

@end
