//
//  PQCheckThinSDK_Tests.m
//  PQCheckThinSDK_Tests
//
//  Created by CJ on 02/03/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <PQCheckSDK/APIManager.h>
#import <PQCheckSDK/Authorisation.h>
#import "ILTesting/ILCannedURLProtocol.h"
#import "MockedPQCheckServer.h"

SPEC_BEGIN(PQCheckAPI)

describe(@"PQCheck API", ^{
    
    beforeEach(^{

        [NSURLProtocol registerClass:[ILCannedURLProtocol class]];
        
        [ILCannedURLProtocol setCannedStatusCode:200];
        [ILCannedURLProtocol setSupportedMethods:@[@"GET"]];
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
        [headers setObject:@"application/json" forKey:@"Content-Type"];
        [ILCannedURLProtocol setCannedHeaders:headers];
        
    });
    
    afterEach(^{
        
        [NSURLProtocol unregisterClass:[ILCannedURLProtocol class]];
    });
    
    it(@"View Authorisation", ^{
        
        MockedPQCheckServer *delegate = [[MockedPQCheckServer alloc] init];
        [ILCannedURLProtocol setDelegate:delegate];
        
        __block NSString *uploadAttempt = @"";
        
        NSURL *url = [NSURL URLWithString:@"https://pqcheck-application-server/authorisation/bcd767ff-141f-41b0-b9f4-302f7647eba1"];
        [[APIManager sharedManager] viewAuthorisationAtURL:url completion:^(Authorisation *authorisation, NSError *error) {
            if (error == nil)
            {
                uploadAttempt = [[[authorisation links] uploadAttemptPath] href];
            }
        }];
        
        
        [[expectFutureValue(uploadAttempt) shouldEventually] equal:@"https://pqcheck-server/authorisation/bcd767ff-141f-41b0-b9f4-302f7647eba1/attempt"];
    });
});
SPEC_END
