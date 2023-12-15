import Foundation

func stringType(of some: Any) -> String {
    let string = (some is Any.Type) ? String(describing: some) : String(describing: type(of: some))
    return string
}

func check(
    _ condition: Bool,
    _ message: String = "",
    file: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
) {
    if !condition {
        error(message, file: file, line: line, column: column, function: function)
    }
}

private var recursionDetectorDuringFailure: Bool = false

public func errorT<T>(
    _ message: String = "",
    file: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
) -> T {
    let message =
        """
        ###############################
        ### AEROSPACE RUNTIME ERROR ###
        ###############################

        Please report to:
            https://github.com/nikitabobko/AeroSpace/issues/new

        Message: \(message)
        Version: \(Bundle.appVersion)
        Git hash: \(gitHash)
        Coordinate: \(file):\(line):\(column) \(function)
        recursionDetectorDuringFailure: \(recursionDetectorDuringFailure)

        Stacktrace:
        \(getStringStacktrace())
        """
    if !isUnitTest {
        showMessageToUser(
            filename: recursionDetectorDuringFailure ? "runtime-error-recursion.txt" : "runtime-error.txt",
            message: message
        )
    }
    if !recursionDetectorDuringFailure {
        recursionDetectorDuringFailure = true
        beforeTermination()
    }
    fatalError(message)
}

func printStacktrace() { print(getStringStacktrace()) }
func getStringStacktrace() -> String { Thread.callStackSymbols.joined(separator: "\n") }

@inlinable func error(
    _ message: String = "",
    file: String = #file,
    line: Int = #line,
    column: Int = #column,
    function: String = #function
) -> Never {
    errorT(message, file: file, line: line, column: column, function: function)
}

func interceptTermination(_ _signal: Int32) {
    signal(_signal, { signal in
        check(Thread.current.isMainThread)
        beforeTermination()
        exit(signal)
    } as sig_t)
}

func beforeTermination() {
    makeAllWindowsVisibleAndRestoreSize()
    if isDebug {
        sendCommandToReleaseServer(command: "enable on")
    }
}

private func makeAllWindowsVisibleAndRestoreSize() {
    for app in apps { // Make all windows fullscreen before Quit
        for window in app.detectNewWindowsAndGetAll(startup: false) {
            // makeAllWindowsVisibleAndRestoreSize may be invoked when something went wrong (e.g. some windows are unbound)
            // that's why it's not allowed to use `.parent` call in here
            let monitor = window.getCenter()?.monitorApproximation ?? mainMonitor
            let monitorVisibleRect = monitor.visibleRect
            let windowSize = window.lastFloatingSize ?? CGSize(width: monitorVisibleRect.width, height: monitorVisibleRect.height)
            window.setSize(windowSize)
            window.setTopLeftCorner(CGPoint(
                x: (monitorVisibleRect.width - windowSize.width) / 2,
                y: (monitorVisibleRect.height - windowSize.height) / 2
            ))
        }
    }
}

var allMonitorsRectsUnion: Rect {
    monitors.map(\.rect).union()
}

extension String? {
    var isNilOrEmpty: Bool { self == nil || self == "" }
}

public var isUnitTest: Bool { NSClassFromString("XCTestCase") != nil }

extension CaseIterable where Self: RawRepresentable, RawValue == String {
    static var unionLiteral: String {
        "(" + allCases.map(\.rawValue).joined(separator: "|") + ")"
    }
}

var apps: [AbstractApp] {
    isUnitTest
        ? appForTests.asList()
        : NSWorkspace.shared.runningApplications.lazy.filter { $0.activationPolicy == .regular }.map(\.macApp).filterNotNil()
}

func terminateApp() -> Never {
    NSApplication.shared.terminate(nil)
    error("Unreachable code")
}

extension Int {
    func toDouble() -> Double { Double(self) }
}

extension String {
    func removePrefix(_ prefix: String) -> String {
        hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
    }

    func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(self, forType: .string)
    }
}

extension Double {
    var squared: Double { self * self }
}

extension Slice {
    func toArray() -> [Base.Element] { Array(self) }
}

func -(a: CGPoint, b: CGPoint) -> CGPoint {
    CGPoint(x: a.x - b.x, y: a.y - b.y)
}

func +(a: CGPoint, b: CGPoint) -> CGPoint {
    CGPoint(x: a.x + b.x, y: a.y + b.y)
}

extension CGPoint: Copyable {}

extension CGPoint {
    /// Distance to ``Rect`` outline frame
    func distanceToRectFrame(to rect: Rect) -> CGFloat {
        let list: [CGFloat] = ((rect.minY..<rect.maxY).contains(y) ? [abs(rect.minX - x), abs(rect.maxX - x)] : []) +
            ((rect.minX..<rect.maxX).contains(x) ? [abs(rect.minY - y), abs(rect.maxY - y)] : []) +
            [distance(to: rect.topLeftCorner),
             distance(to: rect.bottomRightCorner),
             distance(to: rect.topRightCorner),
             distance(to: rect.bottomLeftCorner)]
        return list.minOrThrow()
    }

    func coerceIn(rect: Rect) -> CGPoint {
        CGPoint(x: x.coerceIn(rect.minX...(rect.maxX - 1)), y: y.coerceIn(rect.minY...(rect.maxY - 1)))
    }

    func addingXOffset(_ offset: CGFloat) -> CGPoint { CGPoint(x: x + offset, y: y) }
    func addingYOffset(_ offset: CGFloat) -> CGPoint { CGPoint(x: x, y: y + offset) }
    func addingOffset(_ orientation: Orientation, _ offset: CGFloat) -> CGPoint { orientation == .h ? addingXOffset(offset) : addingYOffset(offset) }

    func getProjection(_ orientation: Orientation) -> Double { orientation == .h ? x : y }

    var vectorLength: CGFloat { sqrt(x*x - y*y) }

    func distance(to point: CGPoint) -> Double {
        sqrt((x - point.x).squared + (y - point.y).squared)
    }

    var monitorApproximation: Monitor {
        let monitors = monitors
        return monitors.first(where: { $0.rect.contains(self) })
            ?? monitors.minByOrThrow { distanceToRectFrame(to: $0.rect) }
    }
}

extension CGFloat {
    func div(_ denominator: Int) -> CGFloat? {
        denominator == 0 ? nil : self / CGFloat(denominator)
    }

    func coerceIn(_ range: ClosedRange<CGFloat>) -> CGFloat {
        if self > range.upperBound {
            return range.upperBound
        } else if self < range.lowerBound {
            return range.lowerBound
        } else {
            return self
        }
    }
}

extension CGSize {
    func copy(width: Double? = nil, height: Double? = nil) -> CGSize {
        CGSize(width: width ?? self.width, height: height ?? self.height)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension Set {
    func toArray() -> [Element] { Array(self) }
}

func debug(_ msg: Any) {
    if isDebug {
        print(msg)
    }
}

#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif
