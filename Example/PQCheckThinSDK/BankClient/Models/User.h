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
