#  Cocoa by Contract

Cocoa by Contract is an implementation of contract checking inspired by Eiffel's [Design by Contract](http://www.design-by-contract.com), suitable for enforcing contracts on Objective-C and Swift classes.

## Usage

Where a client wants to use an instance `obj` of your class `MyClass`, give them this object instead:

    MyClass *enforcingObj = [ContractEnforcer enforcerWithTarget:obj]; // ObjC
    let enforcingObj:MyClass = ContractEnforcer.enforcer(withTarget:obj)  // Swift

Now you have the opportunity to implement methods that test your class's invariant, and the preconditions and postconditions of each method.

### Invariants

An invariant is a condition that should always hold for a _quiescent_ object. That is, if the object is not currently executing a method, the invariant must be true. For example, the length of data received by a download object must always be less than or equal to the size of the file being downloaded; or the number of rows managed by a table data source must be equal to the number of objects in its model.

Implement a method `- (BOOL)invariant` (ObjC), `func invariant() -> Bool` (Swift) to encapsulate the invariant tests. The invariant is checked when you initially create the `ContractEnforcer`, and after every subsequent method invocation. Cocoa By Contract will throw if the invariant returns `NO` or `false`.

### Preconditions

A precondition is a condition that should be true _before_ a method is invoked. Preconditions can check the object's lifecycle (for example don't begin a running operation, or cancel one that isn't running), or that parameters are valid (for example don't ask for the -3rd element of a collection).

Implement a method with the same signature as the method being tested, prefixed by `pre_`, returning a Boolean. Examples:

    - (BOOL)pre_doTheThingWith:(NSString *)argument; // ObjC
    func pre_doTheThing(with argument:String) -> Bool // Swift

Cocoa by Contract will call the method automatically before calling `-doTheThingWith:`/`doTheThing(with:)`. It will throw if the precondition returns `NO` or `false`.

### Postconditions

A postcondition is a condition that should be true _after_ a method is invoked. Postconditions can check the object's lifecycle (for example after pausing a debugger, it should not be executing any statements), and test properties of the return value (for example the result of sorting a list should contain all of the elements present in the input list).

Postconditions have different signatures depending on whether the method being tested returns anything. For `void`/`Void` methods, create a method with the same signature as the method being tested, prefixed by `post_`, returning a Boolean. Examples:

    - (BOOL)post_doTheThingWith:(NSString *)argument; // ObjC
    func post_doTheThing(with argument:String) -> Bool // Swift

If the method returns a value of any type, add a parameter `returning:` to the end of the postcondition's method signature. Examples:

    - (BOOL)post_sortMessages:(NSArray <Message *>*)messages returning:(NSArray <Message *>*)result; // ObjC
    func post_sort(messages: [Message] returning: [Message]) -> Bool // Swift

## Limitations

Swift support for Cocoa by Contract is limited to classes that bridge to Objective-C. Particularly, the methods used by clients of the class must have the `@objc dynamic` annotation, or Cocoa by Contract will crash at runtime.

## License

Cocoa by Contract is licensed under the terms of the [MIT License](https://opensource.org/licenses/MIT), see the file COPYING for more information.
