struct GetWorkspaceMonitorsCommand: QueryCommand {
    func run() -> String {
        check(Thread.current.isMainThread)
        return monitors
            .map { monitor in
                return monitor.name
            }
            .joined(separator: " ")
    }
}
