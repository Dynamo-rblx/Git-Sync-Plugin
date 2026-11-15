## Choose a Pull Operation

<!-- Compare Pull Selected in the Menu with Pull Directory in Repository Viewer. A small table can explain purpose, required selection, destination, and overwrite behavior. -->

## Pull Selected Scripts

<!-- Walk through choosing the repository/branch, selecting existing Studio scripts or their ancestors, clicking Pull Selected, and confirming. -->

<!-- Explain that this updates existing selected scripts instead of importing all other repository files. Source is replaced, so users should preserve local edits they intend to keep. -->

## Pull a Directory or Entire Repository

<!-- Explain opening Repository Viewer, navigating into the desired folder, and clicking Pull Directory. At the repository root, the same button imports the whole repository's supported scripts. -->

<!-- Explain that directory pulling creates instances rather than updating matching existing scripts, so repeating an import can create duplicates. -->

## Choose the Import Destination

<!-- Explain selecting one Studio instance as the destination, or selecting nothing to default to Workspace. Multiple selected destinations are rejected. -->

<!-- Describe service-folder placement when importing from the repository root into Workspace. Include a concrete example of the resulting hierarchy. -->

## How Scripts Are Matched and Tracked

<!-- Explain GitSyncRepository and GitSyncPath on imported scripts. Pull Selected uses that saved association; unlinked scripts use their Studio hierarchy plus .lua. -->

<!-- Explain that scripts associated with a different repository are skipped. Link to the relevant Troubleshooting entries. -->

## Supported Files and Script Properties

<!-- Cover .lua and .luau imports, folder structure, ScriptType metadata, and RunContext preservation. Explain the default Script class when type metadata is absent. -->

<!-- Explain that Pull Selected rejects conflicting ScriptType metadata rather than changing the class of an existing instance. -->

## Verify the Result

<!-- Explain checking the imported instances or updated source, the selected branch, and Studio's Output. Link to Troubleshooting for duplicates, missing files, and type mismatches. -->