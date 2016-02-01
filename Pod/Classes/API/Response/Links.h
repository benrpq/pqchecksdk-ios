//
//  Links.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URIPath.h"

@interface Links : NSObject

@property (nonatomic, strong) URIPath *selfPath;
@property (nonatomic, strong) URIPath *uploadAttemptPath;

+ (NSDictionary *)mapping;

@end
