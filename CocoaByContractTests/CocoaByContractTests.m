//
//  CocoaByContractTests.m
//  CocoaByContractTests
//
//  Created by Graham Lee on 05/03/2019.
//  Copyright © 2019 Labrary, Ltd.
//

#import <XCTest/XCTest.h>
#import "../CocoaByContract/CocoaByContract.h"

@interface CocoaByContractTests : XCTestCase

@end

@implementation CocoaByContractTests

- (void)testMethodsWithoutContractAreForwardedToReceiver {
    NSString *aString = [ContractEnforcer enforcerWithTarget:@"Hello, world!"];
    NSString *result = nil;
    XCTAssertNoThrow(result = [aString uppercaseString], @"No contract to enforce, no exception");
    XCTAssertEqualObjects(result, @"HELLO, WORLD!", @"Enforcer doesn't modify the message");
}
@end
