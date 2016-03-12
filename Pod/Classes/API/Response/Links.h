//
//  Links.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HATEOASObject.h"

/**
 *  The `Links` object contains two locations, firstly the location of the authorisation object itself and secondly the location to which a selfie video can be uploaded.
 */
@interface Links : NSObject

/**
 *  The location of the owner of `Links` object, i.e. `Authorisation` object.
 *
 *  @see HATEOASObject class
 *  @see Authorisation class
 */
@property (nonatomic, strong) HATEOASObject *selfPath;

/**
 *  The location to upload a selfie video.
 *
 *  @see HATEOASObject class
 */
@property (nonatomic, strong) HATEOASObject *uploadAttemptPath;

+ (NSDictionary *)mapping;

@end
