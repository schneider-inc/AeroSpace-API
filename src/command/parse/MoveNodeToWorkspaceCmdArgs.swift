private struct RawMoveNodeToWorkspaceCmdArgs: RawCmdArgs {
    var target: RawWorkspaceTarget?
    var wrapAroundNextPrev: Bool?

    static let info = CmdInfo<Self>(
        help: """
              USAGE: move-node-to-workspace [-h|--help] [--wrap-around] (next|prev)
                 OR: move-node-to-workspace [-h|--help] <workspace-name>

              OPTIONS:
                -h, --help              Print help
                --wrap-around           Make it possible to move nodes between first and last workspaces
                                        (alphabetical order) using (next|prev)

              ARGUMENTS:
                <workspace-name>        Workspace name to move focused window to
              """,
        options: ["--wrap-around": trueBoolFlag(\.wrapAroundNextPrev)],
        arguments: [ArgParser(\.target, parseRawWorkspaceTarget)]
    )
}

struct MoveNodeToWorkspaceCmdArgs: CmdArgs, Equatable {
    let kind: CmdKind = .moveNodeToWorkspace
    let target: WorkspaceTarget
}

func parseMoveNodeToWorkspaceCmdArgs(_ args: [String]) -> ParsedCmd<MoveNodeToWorkspaceCmdArgs> {
    parseRawCmdArgs(RawMoveNodeToWorkspaceCmdArgs(), args)
        .flatMap { raw in
            guard let target = raw.target else {
                return .failure("<workspace-name> is mandatory argument")
            }
            return target.parse(wrapAround: raw.wrapAroundNextPrev, autoBackAndForth: false).flatMap { target in
                .cmd(MoveNodeToWorkspaceCmdArgs(target: target))
            }
        }
}
