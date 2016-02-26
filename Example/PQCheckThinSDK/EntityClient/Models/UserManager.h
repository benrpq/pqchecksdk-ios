//
//  UserManager.h
//  PQCheckSDK
//
//  Created by CJ Tjhai on 26/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

@property (nonatomic, copy) NSString* currentUserIdentifer;

+ (UserManager *)defaultManager;
- (void)addEnroledUser:(NSString *)userIdentifier;
- (NSSet *)enroledUsers;
- (BOOL)isUserEnroled:(NSString *)userIdentifier;

@end
