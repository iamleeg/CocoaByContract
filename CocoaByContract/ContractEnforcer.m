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
    [invocation invokeWithTarget:_receiver];
}

+ enforcerWithTarget:target
{
    return [[self alloc] initWithTarget:target];
}

@end
