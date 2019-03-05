//
//  CocoaByContract.m
//  CocoaByContract
//
//  Created by Graham Lee on 05/03/2019.
//  Copyright © 2019 Labrary, Ltd.
//

#import "ContractEnforcer.h"

@interface NSObject (DesignByContract)

- (BOOL)invariant;

@end

@implementation ContractEnforcer
{
    id _receiver;
}

- (id)initWithTarget:(id)target
{
    _receiver = target;
    if ([_receiver respondsToSelector:@selector(invariant)]) {
        NSAssert([_receiver invariant], @"Expect the invariant to initially hold");
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_receiver methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *methodName = NSStringFromSelector([invocation selector]);
    NSString *preMethodName = [NSString stringWithFormat:@"pre_%@", methodName];
    SEL preMethod = NSSelectorFromString(preMethodName);
    if ([_receiver respondsToSelector:preMethod]) {
        NSMethodSignature *preSignature = [_receiver methodSignatureForSelector:preMethod];
        NSInvocation *invokePrecondition = [NSInvocation invocationWithMethodSignature:preSignature];
        for (int i = 2; i < [preSignature numberOfArguments]; i++) {
            void *argument = NULL;
            [invocation getArgument:&argument atIndex:i];
            [invokePrecondition setArgument:&argument atIndex:i];
        }
        [invokePrecondition setSelector:preMethod];
        [invokePrecondition invokeWithTarget:_receiver];
        BOOL satisfied = NO;
        [invokePrecondition getReturnValue:&satisfied];
        NSAssert(satisfied, @"precondition failure invoking [%@ %@]", _receiver, methodName);
    }

    [invocation invokeWithTarget:_receiver];

    BOOL hasReturn = strcmp([[invocation methodSignature] methodReturnType], "v");
    NSString *postMethodName;
    if (hasReturn) {
        postMethodName = [NSString stringWithFormat:@"post_%@returning:", methodName];
    } else {
        postMethodName = [NSString stringWithFormat:@"post_%@", methodName];
    }
    SEL postMethod = NSSelectorFromString(postMethodName);
    if ([_receiver respondsToSelector:postMethod]) {
        NSMethodSignature *postSignature = [_receiver methodSignatureForSelector:postMethod];
        NSInvocation *invokePostcondition = [NSInvocation invocationWithMethodSignature:postSignature];
        for (int i = 2; i < [[invocation methodSignature] numberOfArguments]; i++) {
            void *argument = NULL;
            [invocation getArgument:&argument atIndex:i];
            [invokePostcondition setArgument:&argument atIndex:i];
        }
        if (hasReturn) {
            void *retVal;
            [invocation getReturnValue:&retVal];
            [invokePostcondition setArgument:&retVal atIndex:[postSignature numberOfArguments] - 1];
        }
        [invokePostcondition setSelector:postMethod];
        [invokePostcondition invokeWithTarget:_receiver];
        BOOL satisfied = NO;
        [invokePostcondition getReturnValue:&satisfied];
        NSAssert(satisfied, @"postcondition failure invoking [%@ %@]", _receiver, methodName);
    }

    if ([_receiver respondsToSelector:@selector(invariant)]) {
        NSAssert([_receiver invariant], @"Expect invariant to still hold after [%@ %@]", _receiver, methodName);
    }
}

+ enforcerWithTarget:target
{
    return [[self alloc] initWithTarget:target];
}

@end
