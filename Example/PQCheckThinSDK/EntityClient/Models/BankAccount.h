//
//  BankAccount.h
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BankAccount : NSObject

@property (nonatomic, copy) NSString *sortCode;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *name;

+ (NSDictionary *)mapping;

@end
