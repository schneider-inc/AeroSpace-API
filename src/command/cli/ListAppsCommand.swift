struct ListAppsCommand: QueryCommand {
    func run() -> String {
        check(Thread.current.isMainThread)
        return apps
            .map { app in
                let pid = String(app.pid)
                let appId = app.id ?? "NULL"
                let name = app.name ?? "NULL"
                return [pid, appId, name]
            }
            .toPaddingTable(columnSeparator: " | ")
    }
}

private extension [[String]] {
    func toPaddingTable(columnSeparator: String) -> String {
        let pads: [Int] = transposed.map { column in column.map { $0.count }.max()! }
        return self
            .map { (row: [String]) in
                zip(row, pads)
                    .map { (elem: String, pad: Int) in
                        elem.padding(toLength: pad, withPad: " ", startingAt: 0)
                    }
                    .joined(separator: columnSeparator)
            }
            .joined(separator: "\n")
    }
}

private extension [[String]] {
    var transposed: [[String]] {
        if isEmpty {
            return []
        }
        let table: [[String]] = self
        var result: [[String]] = []
        for columnIndex in 0... {
            if columnIndex < table.first!.count {
                result += [table.map { row in row[columnIndex] }]
            } else {
                break
            }
        }
        return result
    }
}
