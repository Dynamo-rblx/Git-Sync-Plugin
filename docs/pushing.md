## Push Scripts to GitHub

<!-- Define pushing: uploading selected Studio scripts to the configured repository and branch, creating or updating their remote files. State the required setup and write access. -->

## Choose What to Push

<!-- Explain selecting Script, LocalScript, and ModuleScript instances, or selecting ancestors to include their descendant scripts. Explain checking the Menu's selection list before proceeding. -->

<!-- Clarify that selecting a model includes its scripts; it does not upload the model's geometry or general properties. -->

## Choose the Repository and Branch

<!-- Explain checking the Menu's repository setting and Config's branch setting. Link to Plugin Setup and Branches. -->

## How File Paths Are Chosen

<!-- Explain that GitSyncPath preserves an imported script's remote destination, including after the instance moves within Studio. -->

<!-- Explain the fallback for scripts without a saved path: their Studio hierarchy plus .lua, such as ServerScriptService/Main.lua. -->

<!-- Explain that scripts linked through GitSyncRepository to a different repository are skipped. Link to Troubleshooting for inspecting or deliberately changing these attributes. -->

## Push and Confirm

<!-- Walk through clicking Push Selected, reviewing the confirmation, and checking the result in Output or on GitHub. Explain that an existing remote file at the destination can be overwritten. -->

<!-- Describe the commit behavior actually shipped: the currently uploaded implementation creates a separate commit for each script. Update this description if batch pushing is implemented before release. -->

## Script Source and Metadata

<!-- Explain that pushing reads the current source from Studio's script editor. Cover the ScriptType and RunContext metadata GitSync adds to remote source files and uses when pulling. -->

<!-- Link to Pulling for the reverse operation and Troubleshooting for failed pushes. -->