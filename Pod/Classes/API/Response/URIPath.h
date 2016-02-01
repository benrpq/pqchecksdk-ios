//
//  HRef.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URIPath : NSObject

@property (nonatomic, copy) NSString *href;

+ (NSDictionary *)mapping;

@end
