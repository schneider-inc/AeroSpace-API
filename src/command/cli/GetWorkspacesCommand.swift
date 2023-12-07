struct GetWorkspacesCommand: QueryCommand {
    func run() -> String {
        check(Thread.current.isMainThread)
        return Workspace.all
            .map { workspace in
                return workspace.name
            }
            .joined(separator: ",")
    }
}
