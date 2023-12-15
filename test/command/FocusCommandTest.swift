import XCTest
@testable import AeroSpace_Debug

/*
todo write tests

test 1
    horizontal
        window1
        vertical
            vertical
                window2 <-- focused
            vertical
                window5
                horizontal
                    window3
                    window4
pre-condition: focus_wrapping force_workspace
action: focus up
expected: mru(window3, window4) is focused

*/

final class FocusCommandTest: XCTestCase {
    override func setUpWithError() throws { setUpWorkspacesForTests() }

    func testParse() {
        XCTAssertTrue(parseCommand("focus --boundaries left").failureMsgOrNil?.contains("Possible values") == true)
        XCTAssertEqual(
            parseCommand("focus --boundaries container left").cmdOrNil?.describe,
            .focusCommand(args: FocusCmdArgs(boundaries: .container, whenBoundariesCrossed: .doNothing, direction: .left))
        )

        XCTAssertEqual(
            parseCommand("focus --boundaries container --boundaries container left").failureMsgOrNil,
            "ERROR: Duplicated argument '--boundaries'"
        )
    }

    func testFocus() {
        XCTAssertEqual(focusedWindow, nil)
        var start: Window!
        Workspace.get(byName: name).rootTilingContainer.apply {
            TestWindow(id: 1, parent: $0)
            start = TestWindow(id: 2, parent: $0)
            TestWindow(id: 3, parent: $0)
        }
        start.focus()
        XCTAssertEqual(focusedWindow?.windowId, 2)
    }

    func testFocusAlongTheContainerOrientation() {
        var start: Window!
        Workspace.get(byName: name).rootTilingContainer.apply {
            start = TestWindow(id: 1, parent: $0)
            TestWindow(id: 2, parent: $0)
        }
        start.focus()

        FocusCommand.new(direction: .right).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 2)
    }

    func testFocusAcrossTheContainerOrientation() {
        var start: Window!
        Workspace.get(byName: name).rootTilingContainer.apply {
            start = TestWindow(id: 1, parent: $0)
            TestWindow(id: 2, parent: $0)
        }
        start.focus()

        FocusCommand.new(direction: .up).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 1)
        FocusCommand.new(direction: .down).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 1)
    }

    func testFocusNoWrapping() {
        var start: Window!
        Workspace.get(byName: name).rootTilingContainer.apply {
            start = TestWindow(id: 1, parent: $0)
            TestWindow(id: 2, parent: $0)
        }
        start.focus()

        FocusCommand.new(direction: .left).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 1)
    }

    func testFocusFindMruLeaf() {
        let workspace = Workspace.get(byName: name)
        var startWindow: Window!
        var window2: Window!
        var window3: Window!
        var unrelatedWindow: Window!
        workspace.rootTilingContainer.apply {
            startWindow = TestWindow(id: 1, parent: $0)
            TilingContainer.newVTiles(parent: $0, adaptiveWeight: 1).apply {
                TilingContainer.newHTiles(parent: $0, adaptiveWeight: 1).apply {
                    window2 = TestWindow(id: 2, parent: $0)
                    unrelatedWindow = TestWindow(id: 5, parent: $0)
                }
                window3 = TestWindow(id: 3, parent: $0)
            }
        }

        XCTAssertEqual(workspace.mostRecentWindow?.windowId, 3) // The latest bound
        startWindow.focus()
        FocusCommand.new(direction: .right).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 3)

        window2.markAsMostRecentChild()
        startWindow.focus()
        FocusCommand.new(direction: .right).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 2)

        window3.markAsMostRecentChild()
        unrelatedWindow.markAsMostRecentChild()
        startWindow.focus()
        FocusCommand.new(direction: .right).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 2)
    }

    func testFocusOutsideOfTheContainer() {
        var start: Window!
        Workspace.get(byName: name).rootTilingContainer.apply {
            TestWindow(id: 1, parent: $0)
            TilingContainer.newVTiles(parent: $0, adaptiveWeight: 1).apply {
                start = TestWindow(id: 2, parent: $0)
            }
        }
        start.focus()

        FocusCommand.new(direction: .left).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 1)
    }

    func testFocusOutsideOfTheContainer2() {
        var start: Window!
        Workspace.get(byName: name).rootTilingContainer.apply {
            TestWindow(id: 1, parent: $0)
            TilingContainer.newHTiles(parent: $0, adaptiveWeight: 1).apply {
                start = TestWindow(id: 2, parent: $0)
            }
        }
        start.focus()

        FocusCommand.new(direction: .left).runOnFocusedSubject()
        XCTAssertEqual(focusedWindow?.windowId, 1)
    }
}

extension FocusCommand {
    static func new(direction: CardinalDirection) -> FocusCommand {
        FocusCommand(args: FocusCmdArgs(boundaries: .workspace, whenBoundariesCrossed: .doNothing, direction: direction))
    }
}
