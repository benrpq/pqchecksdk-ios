//
//  Enrolment.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 24/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class implements an enrolment representation object. It contains two items, namely `uri` and `transcript`. The user to be enroled is expected to perform a selfie reading the `transcript` and upload the resulting video to `uri`.
 *
 *  This representation is returned by `[BankClientManager enrolUserWithUUID:completion:]` method of `BankClientManager` class.
 */
@interface Enrolment : NSObject

/**
 *  The URI to which the enrolment video selfie can be send.
 */
@property (nonatomic, copy) NSString *uri;

/**
 *  The transcript that a user needs to read while doing enrolment selfie.
 */
@property (nonatomic, copy) NSString *transcript;

/**
 *  The JSON mapping required by RestKit
 *
 *  @return The RestKit mapping dictionary
 */
+ (NSDictionary *)mapping;

@end
