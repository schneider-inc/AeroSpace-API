struct GetWorkspaceMonitorsCommand: QueryCommand {
    func run() -> String {
        check(Thread.current.isMainThread)
        return monitors.description.joined(" ")
    }
}

