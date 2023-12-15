struct SplitCmdArgs: CmdArgs {
    let kind: CmdKind = .split
    let arg: SplitArg

    enum SplitArg: String, CaseIterable {
        case horizontal, vertical, opposite
    }
}

private struct RawSplitCmdArgs: RawCmdArgs {
    var arg: SplitCmdArgs.SplitArg?

    static let info = CmdInfo<Self>(
        help: """
              USAGE: split [-h|--help] \(SplitCmdArgs.SplitArg.unionLiteral)

              OPTIONS:
                -h, --help   Print help
              """,
        options: [:],
        arguments: [ArgParser(\.arg, parseSplitArg)]
    )
}

func parseSplitCmdArgs(_ args: [String]) -> ParsedCmd<SplitCmdArgs> {
    parseRawCmdArgs(RawSplitCmdArgs(), args)
        .flatMap { raw in
            guard let arg = raw.arg else {
                return .failure("split argument isn't specified")
            }
            return .cmd(SplitCmdArgs(
                arg: arg
            ))
        }
}

private func parseSplitArg(_ arg: String) -> Parsed<SplitCmdArgs.SplitArg> {
    parseEnum(arg, SplitCmdArgs.SplitArg.self)
}
