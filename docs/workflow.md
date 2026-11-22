## Some Background on Git

Assuming you're unfamiliar with all 3 technologies, the first thing you should know is that they are 3 distinct things.

Git is an application installed locally on your computer. It allows you intricate control over your coding project's history as a branching timeline. It's essentially Google Doc's version history on steroids.

Every Git project is called a **repository**, and you can think of it as the folder that your entire project is contained within. Each entry to the timeline is called a **commit**. A single commit stores changed files, a reference to the previous commit, and cosmetics like an id, message, etc.

The fact that all commits point to their predecessor allows for the branching structure of version history, where multiple commits can stem from the same origin. We call each of these paths a **branch**, and it's relatively intuitive to visualize. **Merging** is when you combine branches by applying the changes present up to the latest commit on one branch as a single new commit whose predecessor is the latest commit on another branch.

## GitHub

GitHub isn't the same as Git. Evidently. It is getting its own section.

Unlike Git, GitHub is a cloud-hosted platform. GitHub stores your uploaded Git repositories in a cloud database, and is intended to support collaboration and cross-device programming work.

You can clone repositories from GitHub to your local device, or create new GitHub repositories from your existing local Git repository. Either way, assuming you have a Git repository and a matching GitHub-hosted repository, you'll find they're not inherently in-sync, because they are not one and the same. We call the corresponding GitHub-hosted repository the **remote**. You can have multiple remotes, but that's irrelevant here.

To get the latest version of the remote for local reference, you **fetch** them. If the remote is ahead (has newer commits), you can implement those commits on your local repository by **pulling** them. Inversely, if your local repository is ahead on commits, you can implement those on the remote via **pushing**. Oftentimes when your repositories are out-of-sync, you need to do both and reconcile conflicts.

## GitSync

So how does this all come together? We haven't over everything either Git or GitHub has to offer, but rather the parts that are directly relevant to the plugin. There is no "local repository" when it comes to GitSync. At least not in the same sense as Git, and at least not yet.

It's worth pointing out the purpose of GitSync, which is to focus on integrating Roblox Studio with GitHub. The current vision involves leaving repository administration tasks like pull requests, merging, policy, etc. primarily to GitHub's proven systems, rather than recreating the wheel. Meanwhile, the focus is on extending and adapting capabilities to allow for intuitive interface on the Roblox Studio end of things.

Essentially, GitSync features are meant to improve our ability to preserve and understand work done in Roblox Studio.

With a vague mission statement like that, you might be inclined to ask about things like diff view and version-controlling instances beyond scripts. And you'd be right to. In general, when considering feature requests or suggested improvements, returning to this mission statement might help.

## A Brief Setup Guide

Let's assume you've got the plugin installed and that you can see the Menu, Config, and Info icons in the plugin toolbar.

Before you can even connect a repository, you need to create a **classic** token on GitHub by going to `Settings -> Developer Settings` (it's intuitive from there) and allowing `repo` permissions. Copy the token, because you only get to see it once.

Open the Menu window, and paste your token into the text-box below the top one. The plugin hides your token on de-selection and saves your information across sessions.

Next, you need to copy the `username/repository_name` part of the repository you want to use. It doesn't matter whether you just made it or whether it's someone else's public repo. Paste the phrase you copied in the top text-box on the same Menu window.

You're all set up for action.

<!-- TODO Can we make it so that hovering over a piece of text within "keyword" tags triggers a small vertically-scrollabe width-wise-rectangular pop-up that displays an associated definition from a dataset? -->

> For more details on plugin setup, visit the dedicated <button class="nav-guide" style="color: var(--theme-accent);" data-highlight-pages="plugin-setup">Plugin Setup</button> page.

<!-- Walk through connecting a repository, selecting scripts, pushing, making changes, and pulling updates when needed. Link to the detailed setup and feature pages. -->

## An Overview of Operations

GitSync enables pushing, pulling, branch-selection, and remote repository browsing. It does **not** run operations automatically. Thus, editing a script does not automatically synchronize it. And in-case of a problem, all operations are programmed to be reversable.

To upload scripts, you push them. You select scripts or ancestors of scripts in the Studio Explorer, and you press the push button. Selected scripts whose paths match existing GitHub repository paths will update the script in the repository on the corresponding path. If there is no existing path, a new file corresponding with the script will be created.

To import scripts or directories, you pull them. When pulling scripts, those with paths matching existing repository scripts will be overwritten. Pulling directories, however, will **never** overwrite existing scripts.

To switch branches, you either type or select a branch from the Config window.

Lastly (and importantly), the destinatiomn/source of pushing and pulling operations are decided by your branch, repository, and the attribute metadata on each script. Pulled scripts have easily-removable metadata attributes storing the path and repository just so that they can be pushed to the correct corresponding script even if they are moved. Scripts without these attributes are just organized automatically by their absolute path in Studio.

> For more information on pushing, pulling, and branches, visit the dedicated <button class="nav-guide" style="color: var(--theme-accent);" data-highlight-pages="plugin-setup">Plugin Setup</button> page.

## Working with Branches

As earlier stated, GitSync facilitates branch creation and branch switching. Unlike Git's branch-switching mechanism, GitSync does not automatically change the code in all of your scripts.

Rather, the Repository Viewer will display the contents of the current branch according to that branch's latest commit. Updating scripts to match the information on the current branch requires a manual pull operation with the relevant scripts selected.

The plugin leaves pull request, review, and other merge behavior to GitHub, since the GitHub site's existing merge/PR interface already makes these potentially complex operations very efficient to work with.

So you cannot open pull requests or merge branches remotely. And, you cannot create or otherwise handle local branches. They don't exist. As we established, GitSync is *not* a copy of Git adapted to Roblox Studio: there is no real local repository.

## Collaboration

One big risk of multiple programmers collaborating with GitSync is stepping on each other's feet. That is, overwriting each other's edits due to a lack of coordination.

Using the Repository Viewer, you can manually compare the latest commit on your current branch to what's actually in your current code using the file preview operation (clicking any file in the Viewer).

You can also review the changes made after pushing by viewing the GitHub commit and roll it back if anything went wrong.

You want to make sure you're changing what you want to change to what you want to change to. What a sentence. Basically, if you have A -> B, you want to make sure A and B are both exactly what you think they are, or you could end up having to roll back implementation.

More comprehensive file-comparison and staged-change-preview features are planned.

Since no operation is automatic, GitSync does not provide continuous synchronization. There is no notification from the plugin that a new commit has been made on your repository or branch, so you'd want to (one way or another) communicate and listen to your team intently when it comes to updates.

Because Roblox Studio enables multiple collaborators to work remotely on the same game together, collaboration via GitHub is not hugely relevant. It'd mostly come into play in individually unique situations. Even when collaborators are working in different places, on the same game, there are linked packages for that.

<!-- Explain checking the selected branch and remote changes before replacing scripts. Cover coordinating edits and reviewing changes on GitHub. -->

<!-- Explain that GitSync does not currently provide automatic conflict merging or continuous synchronization. -->