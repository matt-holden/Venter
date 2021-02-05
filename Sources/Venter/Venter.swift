//
//  File.swift
//  
//
//  Created by Matt Holden on 2/5/21.
//

import Foundation


/// Describes a type that can produce events
/// - note: Only final class types can conform to this protocol.
/// After declaring its adoption, default implementations of its requirements
/// are provided.  Use those.
public protocol Venter: class {

    /// Sends `event` from this object instance
    func send(event: Vent<Self, Void>)

    /// Sends `event` with `data`  from this object instance
    func send<Data>(event: Vent<Self, Data>, data: Data)

    /// Register `callback` to execute whenver this object instance dispatches `event`
    func receive<Data>(event: Vent<Self, Data>, with callback: @escaping (Data) -> Void) -> Observation

    /// Sends `event` from this class type
    static func send(event: StaticVent<Self, Void>)

    /// Sends `event` with `data`  from this class.
    /// The unconventional order of these parameters makes autocompletion
    /// in xcode work 10x better. ¯\_(ツ)_/¯
    static func send<Data>(event: StaticVent<Self, Data>, data: Data)

    /// Register `callback` to execute whenver this class dispatches `event`
    static func receive<Data>(event: StaticVent<Self, Data>, with callback: @escaping (Data) -> Void) -> Observation
}

// MARK: Default Implementaitons

public extension Venter {
    static func send(event: StaticVent<Self, Void>) {
        EventCenter.shared.send(event: event, data: Void())
    }

    static func send<Data>(event: StaticVent<Self, Data>, data: Data) {
        EventCenter.shared.send(event: event, data: data)
    }

    @discardableResult
    static func receive<Data>(event: StaticVent<Self, Data>, with callback: @escaping (Data) -> Void) -> Observation{
        EventCenter.shared.receive(event: event, sender: nil, callback: callback)
    }

    func send(event: Vent<Self, Void>) {
        EventCenter.shared.send(event: event, data: Void())
    }

    func send<Data>(event: Vent<Self, Data>, data: Data) {
        EventCenter.shared.send(event: event, data: data)
    }

    @discardableResult
    func receive<Data>(event: Vent<Self, Data>, with callback: @escaping (Data) -> Void) -> Observation {
        EventCenter.shared.receive(event: event, sender: self, callback: callback)
    }
}
