//
//  File.swift
//  
//
//  Created by Matt Holden on 2/5/21.
//

import Foundation

/// A reference returned when registering for event notificaitons
/// that you can use to stop the subscription
public protocol Observation {
    func unsubscribe()
}

extension Array where Element == Observation {
    func unsubscribeAll() {
        for o in self { o.unsubscribe() }
    }
}

private class ObservationImp: Observation, Equatable {
    private weak var senderRef: AnyObject?
    let id = UUID()
    let eventName: String
    var callback: (Any) -> Void

    init<Event: VentType>(event: Event, sender: Event.Sender?, callback cb: @escaping (Event.Data) -> Void) {
        senderRef = sender
        eventName = event.name
        callback = { data in
            guard let data = data as? Event.Data else {
                assertionFailure("This could only happen if EventCenter is buggy.")
                return
            }
            cb(data)
        }
    }

    func unsubscribe() {
        EventCenter.shared.remove(observation: self)
    }

    static func ==(lhs: ObservationImp, rhs: ObservationImp) -> Bool {
        return lhs.id == rhs.id && lhs.senderRef === rhs.senderRef
    }
}

final class EventCenter {
    static let shared = EventCenter()

    // TODO: Thread safe-ify
    private var observations: [String: [ObservationImp]] = [:]

    private init() { }

    func receive<V: VentType, Data>(event: V, sender: V.Sender?, callback: @escaping (Data) -> Void) -> Observation where V.Data == Data {
        let o = ObservationImp(event: event, sender: sender, callback: callback)
        add(observation: o, for: event.name)
        return o
    }

    func send<Event: VentType>(event: Event, data: Event.Data) {
        observations[event.name]?.forEach {
            $0.callback(data)
        }
    }

    private func add(observation: ObservationImp, for name: String) {
        if observations[name] == nil {
            observations[name] = []
        }
        observations[name]!.append(observation)
    }

    fileprivate func remove(observation: ObservationImp) {
        guard var obvs = observations[observation.eventName] else {
            assertionFailure("Highly unexpected...")
            return
        }
        
        for (i, o) in obvs.lazy.enumerated() where o == observation {
            obvs.remove(at: i)
            break
        }
        observations[observation.eventName] = obvs
    }
}
