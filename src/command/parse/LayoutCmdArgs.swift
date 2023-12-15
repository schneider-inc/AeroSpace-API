struct LayoutCmdArgs: CmdArgs, Equatable {
    let kind: CmdKind = .layout
    let toggleBetween: [LayoutDescription]

    enum LayoutDescription: String, CaseIterable, Equatable {
        case accordion, tiles
        case horizontal, vertical
        case h_accordion, v_accordion, h_tiles, v_tiles
        case tiling, floating
    }
}

private struct RawLayoutCmdArgs: RawCmdArgs {
    var toggleBetween: [LayoutCmdArgs.LayoutDescription]?

    static let info = CmdInfo<Self>(
        help: """
              USAGE: layout [-h|--help] \(LayoutCmdArgs.LayoutDescription.unionLiteral)...

              OPTIONS:
                -h, --help   Print help
              """,
        options: [:],
        arguments: [ArgParser(\.toggleBetween, parseToggleBetween)]
    )
}

private func parseToggleBetween(arg: String, _ nextArgs: inout [String]) -> Parsed<[LayoutCmdArgs.LayoutDescription]> {
    var args: [String] = []
    args.append(arg)
    while !nextArgs.isEmpty && !nextArgs.first!.starts(with: "-") {
        args.append(nextArgs.next())
    }

    var result: [LayoutCmdArgs.LayoutDescription] = []
    for arg in args {
        if let layout = arg.parseLayoutDescription2() {
            result.append(layout)
        } else {
            return .failure("Can't parse '\(arg)'")
        }
    }

    return .success(result)
}

func parseLayoutCmdArgs(_ args: [String]) -> ParsedCmd<LayoutCmdArgs> {
    parseRawCmdArgs(RawLayoutCmdArgs(), args)
        .flatMap { raw in
            guard let toggleBetween = raw.toggleBetween?.takeIf({ !$0.isEmpty }) else {
                return .failure("layout command must have at least one argument")
            }
            return .cmd(LayoutCmdArgs(toggleBetween: toggleBetween))
        }
}

private extension String {
    // todo rename
    func parseLayoutDescription2() -> LayoutCmdArgs.LayoutDescription? {
        if let parsed = LayoutCmdArgs.LayoutDescription(rawValue: self) {
            return parsed
        } else if self == "list" {
            return .tiles
        } else if self == "h_list" {
            return .h_tiles
        } else if self == "v_list" {
            return .v_tiles
        }
        return nil
    }
}
