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

@property (nonatomic, readwrite, assign) BOOL failingInvariant, failingPrecondition, failingPostcondition;
@property (nonatomic, strong) id queryReturn;

- (void)command;
- query;

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

- (void)testPreconditionFailureCausesExceptionOnMessageSend {
    target.failingPrecondition = YES;
    XCTAssertThrows([enforcedTarget command], @"precondition fails, throw");
}

- (void)testPreconditionPassOnMessageSendDoesNotThrow {
    target.failingPrecondition = NO;
    XCTAssertNoThrow([enforcedTarget command], @"precondition passes, OK");
}

- (void)testPostconditionFailureCausesExceptionOnMessageSend {
    target.failingPostcondition = YES;
    XCTAssertThrows([enforcedTarget command], @"postcondition fails, throw");
}

- (void)testPostconditionPassOnMessageSendDoesNotThrow {
    target.failingPostcondition = NO;
    XCTAssertNoThrow([enforcedTarget command], @"postcondition passes, OK");
}

- (void)testPostconditionHasAccessToMethodReturnValue {
    target.failingPostcondition = NO;
    id result = [enforcedTarget query];
    id storedResult = [enforcedTarget queryReturn];
    XCTAssertEqualObjects(result, storedResult, @"got access to the return value in the postcondition test");
}
@end

@implementation CanFailAnyTime

- (BOOL)invariant { return !self.failingInvariant; }

- (BOOL)pre_command { return !self.failingPrecondition; }
- (void)command {}
- (BOOL)post_command { return !self.failingPostcondition; }

- query { return @"Pass"; }
- (BOOL)post_queryreturning:retVal { self.queryReturn = retVal; return !self.failingPostcondition; }
@end
