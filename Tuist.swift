import ProjectDescription

let tuist = Tuist(
    plugins: [
        .local(path: .relativeToRoot("Tuist/Plugins/SseuDamPlugin"))
    ]
)