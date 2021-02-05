# Venter

### _Strongly-typed pub-sub for Swift._

#### Go on...

Provides the mean to register for events (with dot-syntactic sugar) using strongly-typed closures.

#### Skip to the end...

If you have a class  `Phone`, and have defined a `didReceiveTextMessage` event that will always be broadcast with `String` containing the message.. your code can be, simply:

``` swift
myPhone.receive(event: .didReceiveTextMesage) { messageText in 
    print(type(of: messageText)) // String
}
```

#### How?


Start by declaring that your class can send events by adopting the `Venter` protocolol.  All of the protocol's requirements have default implementations.

```swift 
// Phone.swift

final class Phone: Venter {
}
```

Then, define an extension on the `Vent` class that describes what events your `Phone` class can send:

```swift
extension Vent where Sender == Phone {
    static var didReceiveTextMessage: Vent<Phone, String> { .init() }
}
```

Now you can send these events from your `Phone` class:

```swift 
// Phone.swift

final class Phone: Venter {
    func gotANewMessage() {
        // Notify subscribers
        self.send(event: .didRecieveTextMessage, data: "this is the message I just got")
    }
}
```

And observe like so:

```swift
// Elsewhere.swift
myPhone.receive(event: .didReceiveTextMessage) { message in 
    message is String == true // So true, in fact, that the compiler will whine about it
}
```

#### How did swift infer what `.didReceiveTextMesage` refers to?

Swift knows that the sender of this event is `myPhone`, a `Phone` instance, so the only valid `Vent`s that can be passed to the `receive(event:` parameter are going to be `Vent`s  with a `Sender`  type of `Phone`.  Similarly, Swift's nifty dot-syntax access for statically-defined functions and properties that return the same type they're contained in allows us to refer to this event as easily as though it were an enum case, and just write `.didReceiveTextMessage`.

This (admittedly odd) usage of type constraints gives us some xcode nirvana when we work with it later.  

When we typed the above in Xcode was able to determine what `Vent`s (aka events) are sent by the `Phone` class, and thus only show us those `Phone`-related events in the automcomplete suggestion box.  No matter how many classes you describe `Vent`s for , the ony autocomplete suggestions you'll see are the ones pertinent to the code you're working with.

```
self.send(event: .   // <--- XCode Autocomplete springs to the well-informed rescue
```

### What is a `Vent<Phone, String>`?

`Vent` is a struct that represents an Event.  You don't need to work with them directly, just define them as `static var`s within a type-constrained estension on `Vent`.

The `Vent` struct has two generic parameters, `Sender`, the class whose instances can send the event, and `Data`, the type of data that the event sends.  In our example extension's declaration `static var didReceiveTextMessage`,  `Phone` is the `Sender` type, and `String` is the `Data` type.

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

myInstanceOfSomeType.receive(event: .thisHappened) { (with: String, some: Int, info: String?) in  
    // ... do all the things with all the datas
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

