//
//  GlobalEvents.swift
//  
//
//  Created by Matt Holden on 2/7/21.
//

import Foundation
@testable import Venter


// Note: This class doesn't need to have many members or functions,
// simply declaring that it exists and conforms to Venter is suffiencent
// to use it as a namespace for events defined below
final class MyGlobalEvents: Venter { }

/// Basic of using StaticVent to send events from the  venting class type itself.
extension StaticVent where Sender == MyGlobalEvents {
    static var loggedInUserChanged: StaticVent<MyGlobalEvents, User> { .init() }
}
