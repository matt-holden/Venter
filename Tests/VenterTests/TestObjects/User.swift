//
//  User.swift
//  
//
//  Created by Matt Holden on 2/5/21.
//

import Foundation
@testable import Venter

extension Vent where Sender == User {
    static var didChangeNickame: Vent<User, String?> { .init() }
    static var didLogOut: Vent<User, Void> { .init() }
    static var unreadMessageCountChanged: Vent<User, (old: Int, new: Int)> { .init() }
}

final class User: Venter {
    var nickname: String? {
        didSet {
            self.send(event: .didChangeNickame, data: nickname)
        }
    }

    var unreadMessages: Int = 0 {
        didSet {
            self.send(event: .unreadMessageCountChanged, data: (old: oldValue, new: unreadMessages))
        }
    }

    func logOut() {
        self.send(event: .didLogOut)
    }
}



