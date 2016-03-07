/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

/**
 *  This class implements an enrolment representation object. It contains two items, namely `uri` and `transcript`. The user to be enrolled is expected to perform a selfie reading the `transcript` and upload the resulting video to `uri`.
 *
 *  This representation is returned by `[BankClientManager enrolUserWithUUID:completion:]` method of `BankClientManager` class.
 */
@interface Enrolment : NSObject

/**
 *  The URI to which the enrolment selfie video can be sent.
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
