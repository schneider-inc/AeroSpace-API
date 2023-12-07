struct GetActiveWorkspaceCommand: QueryCommand {
    func run() -> String {
        check(Thread.current.isMainThread)
        return focusedWorkspaceName
    }
}
