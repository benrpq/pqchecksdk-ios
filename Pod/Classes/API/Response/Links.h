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
