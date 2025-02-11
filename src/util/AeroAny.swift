protocol AeroAny {}

extension AeroAny {
    @discardableResult
    @inlinable
    func apply(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }

    @discardableResult
    @inlinable
    func also(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }

    @inlinable func takeIf(_ predicate: (Self) -> Bool) -> Self? { predicate(self) ? self : nil }
    @inlinable func lets<R>(_ body: (Self) -> R) -> R { body(self) }
}

extension TreeNode: AeroAny {}
extension Int: AeroAny {}
extension CGFloat: AeroAny {}
extension Rect: AeroAny {}
extension AXUIElement: AeroAny {}
extension CGPoint: AeroAny {}
extension String: AeroAny {}
extension Character: AeroAny {}
extension AbstractApp: AeroAny {}
extension Regex: AeroAny {}
extension Array: AeroAny {}
