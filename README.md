# 🛠️ My Development Environment 🛠️

This is my personal development environment for Wind0ws and Mac 0S.

Note that this configuration depends on [Git for Wind0ws](https://gitforwindows.org/) in Wind0ws.

## Installation 💻

The following command will install the configuration files in your home directory:

```sh
$ curl -o- https://raw.githubusercontent.com/n0bra1n3r/dotfiles/staging/install.sh | bash
```

This installation script will ask for the configuration values specified in [this file](home/.chezmoi.toml.tmpl).

## Tools and Commands 🧰

### [workspace](home/exact_dot_dotfiles/exact_scripts/workspace) (bash script)

Creates/navigates/deletes [git worktrees](https://opensource.com/article/21/4/git-worktree).

> A git worktree is a linked copy of your Git repository, allowing you to have multiple branches checked out at a time. A worktree has a separate path from your main working copy, but it can be in a different state and on a different branch. The advantage of a new worktree in Git is that you can make a change unrelated to your current task, commit the change, and then merge it at a later date, all without disturbing your current work environment.

💡 **Quick tips**:

* Make sure the script is executable by running `chmod +x workspace`.
* It may be convenient to `alias ws=workspace`.
  * Autocomplete can be enabled for the command in [bash](home/exact_dot_dotfiles/bashrc#L33:L47) and [zsh](home/exact_dot_dotfiles/exact_zshrc/dot_zshrc#L56:L68).

#### `workspace <git-url>`

Creates a new worktree directory `ws-<repo-name>/<default-branch>` for the repository at `<git-url>` in your current directory, and changes the current directory to this directory.

The directory this command is run in must not be inside a git folder.

#### `workspace <branch-name>`

Switches to a worktree corresponding to `<branch-name>`. This command will fetch `<branch-name>` if it does not exist locally.

Autocomplete for bash and zsh are available for this command by pressing the `<Tab>` key.

#### `workspace -`

Switches to the previously visited worktree, if there is one. Works similarly to `git switch -`.

#### `workspace clean [<branch-name> | -- <branch-list>]`

Deletes worktree(s) with no associated remotes. This command will ask for confirmation before deleting a worktree.

A convenient usage is `workspace clean -- $(git branch)`, which will process all worktrees in the current repository.

#### `workspace`

Switches to the worktree corresponding to the default branch.
