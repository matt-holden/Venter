# Venter

### _Strongly-typed pub-sub for Swift._

#### Go on...

Provides the mean to register for events (with all the glory of dot syntax) with closures that are strongly typed according to which event your code is subscribing to.

#### Skip to the end and work backwards.

If I have a class  `Phone`, and have defined a `didReceiveTextMessage` event that will always be broadcast with `String` containing the message.. my code can be, simply:

``` swift
myPhone.receive(event: .didReceiveTextMesage) { messageText in 
    print(type(of: messageText)) // String
}


// inside Phone.swift

func gotANewMessage() {
    // Notify subscribers
    self.send(event: .didRecieveTextMessage, data: "this is the message I just got")
}
```

#### How did swift infer what `.didReceiveTextMesage` was referring to?

Because first, we defined that event inside an extension on the `Vent` class.

```swift
extension Vent where Sender == Phone {
        static var didReceiveTextMessage: Vent<Phone, String> { .init() }
}
```

This admittedly roundabout way of using type constraints gives us some xcode nirvana when we work with it later.  When we typed the following two snippets ago witihin our `Phone` class, Xcode was able to determine what `Vent`s are sent by the `Phone` class, and only show us those in the autocomplete window:

```
self.send(event: .   // <--- XCode Autocomplete springs to the rescue
```


### What is a `Vent<Phone, String>`?

`Vent` is a struct that represents an Event.  You never create these directly, and instead define them as the returned value of `static var`s defined within a type-constrained exteneion on `Vent`.  `Vent` has two generic parameters, `Sender` -> the class whose instances can send the event, and `Data`, the type of data that the event sends.  In our example, `Phone`, and `String` are used for `Sender` and `Data` .

If you were to create a `didReceiveTextMessage` event on a different class, such as `ReallyOldPhone`, they would not conflict, because Xcode will infer which one you're referring to by the context you're using it in (i.e. which type is sending the event.)


### What if I need to pass more than one piece of data with my event?

Use a tuple.  Even better, use a named tuple:

```swift
extension Vent where Sender == SomeType {
    static var thisHappened: Vent<SomeType, (with: String, some: Int, info: String?)>
}


// Elsewhere in SomeType.swift

self.send(event: .thisHappened, data: (with: "hello", some: 2, info: nil))

// Elsewhere, elsewhere:

myInstanceOfSomeType.receive(event: .thisHappened) { (with: String, some: Int, data: String?) in  
    // this works fairly well, right?
}

````

### What if I want to send an event from the class type, not an object instance?

You're in luck!  The syntax is identical, except you would define the event on the `StaticVent`  type instead of on `Vent`.  This separation is purely to ensure you don't dispatch an event from a class instance while attempting to subscribe to it coming from the class type itself.

```swift
public final class AppStateEvents: Venter { }  // Can be a completely empty class

extension StaticVent where Sender == AppStateEvents {
    static var userDidAuthenticate: StaticVent<AppStateEvents, User> { .init() }
}

// Use:

let observer = AppStateEvents.receive(event: .userDidAuthenticate) { user in 
    // do something with `user`
} 

// Later (or never)

observer.unsubscribe()  // Stop this closure from continuing to receive events
```

### Why `Vent`, `StaticVent`, and `Venter`?

It seemed rude to ask developers to import a type called `Event` into their code, as this would be sure to cause collisions... so I went with `Vent`.  That's about it.  The rest is for consistency.

