//
//  User.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 04/03/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class implements a user object
 */
@interface User : NSObject

/**
 *  The identifier of the user
 */
@property (nonatomic, copy) NSString *identifier;

/**
 *  The name or alias of the user
 */
@property (nonatomic, copy) NSString *name;

/**
 *  Initialises the user object from a piece of raw data
 *
 *  @param data The raw data representation of the user
 *
 *  @return Return the initialised user object
 */
- (id)initWithData:(NSData *)data;

/**
 *  Returns the raw data representation of a user
 *
 *  @return The raw data representation
 */
- (NSData *)data;

@end
