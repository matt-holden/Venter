import XCTest
@testable import Venter



final class VenterTests: XCTestCase {


    func testInstanceEvents() {
        let user = User()

        var observers: [Observation] = []

        let expectation1 = expectation(description: "Received new nickname event")
        observers.append(user.receive(event: .didChangeNickame, with: { newNickname in
            XCTAssert(newNickname == "new nickname")
            expectation1.fulfill()
        }))

        let expectation2 = expectation(description: "Received log out notification")
        observers.append(user.receive(event: .didLogOut, with: { _ in
            expectation2.fulfill()
        }))

        let expectation3 = expectation(description: "Recieved inbox count change notification")
        observers.append(user.receive(event: .unreadMessageCountChanged, with: { (old, new) in
            XCTAssert(new == 3)
            expectation3.fulfill()
        }))

        user.nickname = "new nickname"
        user.logOut()
        user.unreadMessages = 3

        observers.unsubscribeAll()

        waitForExpectations(timeout: 0.01) { err in
            XCTAssert(err == nil)
        }
    }

    func testStaticEvents() {
        var observers: [Observation] = []

        let expectation1 = expectation(description: "Did static message")
        observers.append(MyGlobalEvents.receive(event: .loggedInUserChanged, with: { user in
            expectation1.fulfill()
        }))

        MyGlobalEvents.send(event: .loggedInUserChanged, data: User())
        waitForExpectations(timeout: 0.01) { (err) in
            XCTAssert(err == nil)
        }

        observers.unsubscribeAll()
    }

    func testUnregistering() {

        MyGlobalEvents.send(event: .loggedInUserChanged, data: User())
        var callbackInvocationCount = 0
        let observation = MyGlobalEvents.receive(event: .loggedInUserChanged, with: { user in
            callbackInvocationCount += 1
        })

        XCTAssert(callbackInvocationCount == 0)  // Sanity check

        MyGlobalEvents.send(event: .loggedInUserChanged, data: User())

        XCTAssert(callbackInvocationCount == 1)

        observation.unsubscribe() // Unsubscribe

        MyGlobalEvents.send(event: .loggedInUserChanged, data: User())

        XCTAssert(callbackInvocationCount == 1) // Call count should remain unchanged

    }

    func testInstanceSubscriptionDoesNotRetainVenter() {
        var user: User? = User()
        weak var weakRefOfUser: User? = user

        let observer = user!.receive(event: .didChangeNickame) { _ in
            XCTFail("This should never get called in this test.")
        }

        XCTAssert(weakRefOfUser === user) // Sanity check
        user = nil
        XCTAssert(weakRefOfUser == nil)

        _ = observer // Ensures ARC does not deallocate 'observer' before this line
    }
}
