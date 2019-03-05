//
//  CocoaByContract.h
//  CocoaByContract
//
//  Created by Graham Lee on 05/03/2019.
//  Copyright © 2019 Labrary, Ltd.
//

#import <Foundation/Foundation.h>

@interface ContractEnforcer<T> : NSProxy

+ (T)enforcerWithTarget:(T)target;

@end
