import Foundation
import PackagePlugin

@main
final class MySwiftFormatPlugin: BuildToolPlugin {
    enum GeneratorBuildToolError: Error {
        case wrongTargetType
    }

    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let path = context.package.directory
        let tool = try context.tool(named: "swiftformat")

        guard let target = target as? SwiftSourceModuleTarget else {
            throw GeneratorBuildToolError.wrongTargetType
        }

        let commands: [Command] = target
            .sourceFiles(withSuffix: ".swift")
            .compactMap {
                switch $0.type {
                case .source,
                     .header:
                    break
                case .resource,
                     .unknown:
                    return nil
                @unknown default:
                    return nil
                }

                let filePath = $0.path
                return .prebuildCommand(displayName: "Processing \(filePath.lastComponent)",
                                        executable: tool.path,
                                        arguments: [
                                            "--cache", "ignore",
                                            "--config", path.appending(".swiftformat").string,
                                            filePath.string
                                        ],
                                        outputFilesDirectory: filePath)
            }
        return commands
    }
}
