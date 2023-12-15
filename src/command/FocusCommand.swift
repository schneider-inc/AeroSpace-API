struct FocusCommand: Command {
    let args: FocusCmdArgs

    func _run(_ subject: inout CommandSubject, _ index: Int, _ commands: [any Command]) {
        check(Thread.current.isMainThread)
        guard let currentWindow = subject.windowOrNil else { return }
        let workspace = currentWindow.workspace
        // todo bug: floating windows break mru
        let floatingWindows = makeFloatingWindowsSeenAsTiling(workspace: workspace)
        defer {
            restoreFloatingWindows(floatingWindows: floatingWindows, workspace: workspace)
        }
        let direction = args.direction

        guard let (parent, ownIndex) = currentWindow.closestParent(hasChildrenInDirection: direction, withLayout: nil) else { return }
        let windowToFocus = parent.children[ownIndex + direction.focusOffset]
            .findFocusTargetRecursive(snappedTo: direction.opposite)

        if let windowToFocus {
            subject = .window(windowToFocus)
            windowToFocus.focus()
        }
    }
}

private func makeFloatingWindowsSeenAsTiling(workspace: Workspace) -> [FloatingWindowData] {
    let mruBefore = workspace.mostRecentWindow
    defer {
        mruBefore?.focus()
    }
    let floatingWindows: [FloatingWindowData] = workspace.floatingWindows
        .map { (window: Window) -> FloatingWindowData? in
            guard let center = window.getCenter() else { return nil }
            // todo bug: what if there are no tiling windows on the workspace?
            guard let target = center.coerceIn(rect: window.workspace.monitor.visibleRectPaddedByOuterGaps).findIn(tree: workspace.rootTilingContainer, virtual: true) else { return nil }
            guard let targetCenter = target.getCenter() else { return nil }
            guard let tilingParent = target.parent as? TilingContainer else { return nil }
            let index = center.getProjection(tilingParent.orientation) >= targetCenter.getProjection(tilingParent.orientation)
                ? target.ownIndex + 1
                : target.ownIndex
            let data = window.unbindFromParent()
            return FloatingWindowData(window: window, center: center, parent: tilingParent, adaptiveWeight: data.adaptiveWeight, index: index)
        }
        .filterNotNil()
        .sortedBy { $0.center.getProjection($0.parent.orientation) }
        .reversed()

    for floating in floatingWindows { // Make floating windows be seen as tiling
        floating.window.bind(to: floating.parent, adaptiveWeight: 1, index: floating.index)
    }
    return floatingWindows
}

private func restoreFloatingWindows(floatingWindows: [FloatingWindowData], workspace: Workspace) {
    let mruBefore = workspace.mostRecentWindow
    defer {
        mruBefore?.focus()
    }
    for floating in floatingWindows {
        floating.window.unbindFromParent()
        floating.window.bind(to: workspace, adaptiveWeight: floating.adaptiveWeight, index: INDEX_BIND_LAST)
    }
}

private struct FloatingWindowData {
    let window: Window
    let center: CGPoint

    let parent: TilingContainer
    let adaptiveWeight: CGFloat
    let index: Int
}

private extension TreeNode {
    func findFocusTargetRecursive(snappedTo direction: CardinalDirection) -> Window? {
        switch genericKind {
        case .workspace(let workspace):
            return workspace.rootTilingContainer.findFocusTargetRecursive(snappedTo: direction)
        case .window(let window):
            return window
        case .tilingContainer(let container):
            if direction.orientation == container.orientation {
                return (direction.isPositive ? container.children.last : container.children.first)?
                    .findFocusTargetRecursive(snappedTo: direction)
            } else {
                return mostRecentChild?.findFocusTargetRecursive(snappedTo: direction)
            }
        }
    }
}
