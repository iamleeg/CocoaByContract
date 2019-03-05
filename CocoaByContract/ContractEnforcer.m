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

    [invocation invokeWithTarget:_receiver];

    if ([_receiver respondsToSelector:@selector(invariant)]) {
        NSAssert([_receiver invariant], @"Expect invariant to still hold after [%@ %@]", _receiver, methodName);
    }
}

+ enforcerWithTarget:target
{
    return [[self alloc] initWithTarget:target];
}

@end
