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

## An Overview of Operations

GitSync enables pushing, pulling, branch-selection, and remote repository browsing. It does **not** run operations automatically. And in-case of a problem, all operations are programmed to be reversable.

To upload scripts, you push them. You select scripts or ancestors of scripts in the Studio Explorer, and you press the push button. Selected scripts whose paths match existing GitHub repository paths will update the script in the repository on the corresponding path. If there is no existing path, a new file corresponding with the script will be created.

To import scripts or directories, you pull them. When pulling scripts, those with paths matching existing repository scripts will be overwritten. Pulling directories, however, will **never** overwrite existing scripts.

To switch branches, you either type or select a branch from the Config window.

Again, operations are manual. Thus, editing a script does not automatically synchronize it.

Lastly (and importantly), the destinatiomn/source of pushing and pulling operations are decided by your branch, repository, and the attribute metadata on each script. Pulled scripts have easily-removable metadata attributes storing the path and repository just so that they can be pushed to the correct corresponding script even if they are moved. Scripts without these attributes are just organized automatically by their absolute path in Studio.

## Setting Things Up

<!-- Walk through connecting a repository, selecting scripts, pushing, making changes, and pulling updates when needed. Link to the detailed setup and feature pages. -->

## Working with Branches

<!-- Explain using a separate branch for changes. Relate this to GitHub Flow: create a branch, make changes, open a pull request, review, and merge. -->

<!-- Distinguish operations available inside GitSync from pull requests and merging performed on GitHub. Changing GitSync's branch setting does not automatically replace Studio scripts. -->

## Collaboration

<!-- Explain checking the selected branch and remote changes before replacing scripts. Cover coordinating edits and reviewing changes on GitHub. -->

<!-- Explain that GitSync does not currently provide automatic conflict merging or continuous synchronization. -->