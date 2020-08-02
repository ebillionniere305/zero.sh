import Foundation
import Path
import SwiftCLI

final class ApplySymlinksCommand: Command {
    let name: String = "apply-symlinks"
    let shortDescription: String = "Apply symlinks for a workplace"
    @Param var workspace: Workspace?
    @Key("-d", "--directory") var configDirectory: Path?

    final func execute() throws {
        let runner = try ZeroRunner(
            configDirectory: self.configDirectory,
            workspace: self.workspace ?? [],
            verbose: self.verbose
        )
        try runner.workspaceDirectories.forEach(runner.applySymlinks)
    }
}

extension ZeroRunner {
    /// Applies symlinks contained in `symlinks` folder in the given directory.
    func applySymlinks(directory: Path) throws {
        let symlinkDirectory = directory.join("symlinks")
        let symlinks: [Path] = !symlinkDirectory.exists ? [] : symlinkDirectory.ls()
        guard !symlinks.isEmpty else {
            return
        }

        Term.stdout <<< TTY.progressMessage("Applying symlinks...")
        for link in symlinks {
            try Self.runTask(
                "stow",
                link.basename(),
                "--target",
                Path.home.string,
                "--dotfiles",
                "--verbose=1",
                at: symlinkDirectory
            )
        }
        Term.stdout <<< TTY.successMessage("Applied symlinks.")
    }
}
