//
//  CocoaByContractTests.m
//  CocoaByContractTests
//
//  Created by Graham Lee on 05/03/2019.
//  Copyright © 2019 Labrary, Ltd.
//

#import <XCTest/XCTest.h>
#import "../CocoaByContract/CocoaByContract.h"

@interface CanFailAnyTime : NSObject

@property (nonatomic, readwrite, assign) BOOL failingInvariant;

- (void)command;

@end

@interface CocoaByContractTests : XCTestCase

@end

@implementation CocoaByContractTests
{
    CanFailAnyTime *target, *enforcedTarget;
}

- (void)setUp {
    target = [CanFailAnyTime new];
    enforcedTarget = [ContractEnforcer enforcerWithTarget:target];
}

- (void)tearDown {
    target = nil;
    enforcedTarget = nil;
}

- (void)testMethodsWithoutContractAreForwardedToReceiver {
    NSString *aString = [ContractEnforcer enforcerWithTarget:@"Hello, world!"];
    NSString *result = nil;
    XCTAssertNoThrow(result = [aString uppercaseString], @"No contract to enforce, no exception");
    XCTAssertEqualObjects(result, @"HELLO, WORLD!", @"Enforcer doesn't modify the message");
}

- (void)testInvariantCheckedWhenEnforcerSetUp {
    target = [CanFailAnyTime new];
    target.failingInvariant = YES;
    XCTAssertThrows([ContractEnforcer enforcerWithTarget:target], @"invariant fails on setup, throw");
}

- (void)testTargetCreatedWhenInvariantPassesOnSetUp {
    target.failingInvariant = NO;
    XCTAssertNoThrow([ContractEnforcer enforcerWithTarget:target], @"invariant passes on setup, OK");
}

- (void)testInvariantFailureCausesExceptionOnMessageSend {
    target.failingInvariant = YES;
    XCTAssertThrows([enforcedTarget command], @"invariant fails on message, throw");
}

- (void)testInvariantPassOnMessageSendDoesNotThrow {
    target.failingInvariant = NO;
    XCTAssertNoThrow([enforcedTarget command], @"invariant passes on message, OK");
}

@end

@implementation CanFailAnyTime

- (BOOL)invariant { return !self.failingInvariant; }

- (void)command {}

@end
