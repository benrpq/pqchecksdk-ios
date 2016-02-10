//
//  AccountCollection.h
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountCollection : NSObject

@property (nonatomic, copy)   NSString *sortCode;
@property (nonatomic, copy)   NSString *number;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, strong) NSSet *payments;

+ (NSDictionary *)mapping;

@end
