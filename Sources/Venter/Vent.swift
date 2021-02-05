//
//  File.swift
//  
//
//  Created by Matt Holden on 2/5/21.
//

import Foundation

/// Common protocl shared by the Vent and StaticVent structs.
/// There is no use case to adopt this protocol yourself.
public protocol VentType { 
    associatedtype Sender: Venter
    associatedtype Data
    var name: String { get }
}

/// A strongly-typed association an event name, the type of data that is sent with it,
/// and which `Venter`-conforming type's instance can send it
public struct Vent<Sender: Venter, Data>: VentType, Hashable {
    public var name: String

    /// Don't pass a parameter here!
    public init(useTheDefault name: String = #function) {
        self.name = "\(type(of: self))|\(Sender.self)-\(Data.self)|\(name)"
    }
}

/// A strongly-typed association an event name, the type of data that is sent with it,
/// the `Venter`-conforming class type that can send it
/// - :
public struct StaticVent<Sender: Venter, Data>: VentType, Hashable {
    public var name: String 
    
    /// Don't pass a parameter here!
    public init(useTheDefault name: String = #function) {
        self.name = "\(type(of: self))|\(Sender.self)-\(Data.self)|\(name)--static"
    }
}
