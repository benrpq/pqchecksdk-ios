//
//  PQCheckThinSDK_ExampleTests.m
//  PQCheckThinSDK_ExampleTests
//
//  Created by CJ Tjhai on 29/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/RestKit.h>
#import <RestKit/Testing.h>

@interface PQCheckThinSDK_ExampleTests : XCTestCase
{
    NSString *_userIdentifier;
}
@end

@implementation PQCheckThinSDK_ExampleTests

- (BOOL)isValidUUID:(NSString *)uuidStr
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
    return (uuid != nil);
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    //[NSURLProtocol registerClass:[ILCannedURLProtocol class]];
    
    NSBundle *targetBundle = [NSBundle bundleWithIdentifier:@"com.post-quantum.PQCheckThinSDK-ExampleTests"];
    [RKTestFixture setFixtureBundle:targetBundle];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetAccounts {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    _userIdentifier = [[NSUUID UUID] UUIDString];
    
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end
