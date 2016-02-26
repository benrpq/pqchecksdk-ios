//
//  Enrolment.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 24/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Enrolment : NSObject

@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *transcript;

+ (NSDictionary *)mapping;

@end
