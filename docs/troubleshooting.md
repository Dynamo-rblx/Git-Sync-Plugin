## DEF CON 1
> If nothing seems to work, message [Roller_Bott](https://devforum.roblox.com/u/roller_bott/) on DevForum or open a [GitHub Issue](https://github.com/Dynamo-rblx/Git-Sync-Plugin/issues)

## Repository Access Error
There are a few reasons this can happen. First you want to check your repository and token fields.

- Make sure your repository field is in the Owner/Repository format (it is case-sensitive)

- Check that your GitHub token is not expired

- Check that your token gives you access to your specified repository

- Make sure your token is a classic token


## "My push keeps failing"
There are multiple possible causes.

- Check your token's write permissions

- Check your currently selected branch

- Look in Studio's output for specific info on the GitHub error


## What is "script belongs to another repository"
GitSync uses two attributes: `GitSyncRepository` and `GitSyncPath` to track imported items even after they move.

If a selected item's `GitSyncRepository` attribute does not match your current repository setting, then you will receive this warning.

Essentially, all that happens in consequence is that this file is skipped over in whatever operation is being done.

Both `GitSyncRepository` and `GitSyncPath` are user-mutable attributes.


## Why is directory pull creating duplicates?
There are two buttons for pulling. The one inside the repository viewer is for pulling directories.

The directory pull operation, for the sake of tracking and predictability, will never overwrite scripts.

To overwrite scripts with a pull operation, use the pull selected operation in the main menu widget.


## "My empty repository is having branch problems"
Truly empty repositories on GitHub are weird, because without an initial commit, they technically don't even exist.

Before you can create additional branches with the plugin, you need to make an initial commit.

A quick way to do this is by pushing a script.


## "I edited a script through repository viewer and GitHub didn't update"
The script previews from the repository viewer are temporary.

If not for Roblox Studio versioning issues, they'd be read-only as well.

I am sorry for your lost work. If your preview tab is closed, there is nothing we can do.


## Pull Selected can't find a file
GitSync uses two attributes: `GitSyncRepository` and `GitSyncPath` to track imported items even after they move.

Previously GitSync-imported scripts use their saved attrivutes to determine pull source for when they are pushed.

Scripts without these attributes use their Studio hierarchy, resulting in predictable automatic paths like `ServerScriptService/Main.lua`.

