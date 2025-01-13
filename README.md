# common project files
My common files, workflows, and recipes for working on projects

## Usage

> [!note]
> Refer to [Just docs](https://just.systems/man/en/remote-justfiles.html#remote-justfiles)
> for details on using remote Justfiles.

First and foremost, you should copy down [Brewfile](Brewfile),
if you don't already have one;
then install the bundle into the repo

```shell
curl https://raw.githubusercontent.com/griceturrble/justfiles/main/Brewfile > Brewfile
brew bundle install
```

Next, include the following in the project Justfile:

```just
### START COMMON ###
import? 'common.just'

# Show these help docs
help:
    @just --list --unsorted --justfile {{ source_file() }}

# Pull latest common justfile recipes to local repo
[group("commons")]
sync-justfile:
    curl -H 'Cache-Control: no-cache, no-store' \
        https://raw.githubusercontent.com/griceturrble/justfiles/main/Justfile > common.just
### END COMMON ###

# bootstrap the dev environment
bootstrap:
    just sync-justfile
    just bootstrap-commons
```

You can then call `just bootstrap` to call down the common [Justfile](Justfile)
into the project,
as well as bootstrap the common tooling
(such as installing `pre-commit` hooks in the repo).

From there, all targets of that common file should be available natively.

### bootstrap pattern

Note the above sample includes:

```just
# bootstrap the dev environment
bootstrap:
    just sync-justfile
    just bootstrap-commons
```

The call to `sync-justfile` will install the common module.
The very next call to `bootstrap-commons` is able to use the new `common.just` immediately,
which is quite handy. 🙂

You should add whatever other calls you need into the `bootstrap` target
in order to get the whole environment for the target repo up and running:

```just
# bootstrap the dev environment
bootstrap:
    just sync-justfile
    just bootstrap-commons
    uv sync --all-groups
```

...etc. At the end of the process, ideally *one call* to `just bootstrap`
*should* get the project ready for you to start working on it.

### gitignore the common file

This method will add a `common.just` file into your local repo.
You should add this file to `.gitignore` to avoid having it tracked.

## Available recipes

### `bootstrap-commons`

Multiple `boostrap-*` recipes may be available,
which help setup some common tools.
The main entrypoint for these is `bootstrap-commons`,
which calls each of them.

This should be used within a local `bootstrap` recipe
in order to bootstrap the entire project:

```just
bootstrap:
    just bootstrap-commons
    install/something/else
```

This command includes:

- `bootstrap-precommit`: runs `pre-commit install`

### `lint <hook>`

Runs `precommit run <hook> --all-files`,
acting as a linter for the project.
The default `hook` is an empty string,
allowing all hooks to run at once.
In this way, `just lint` runs all hooks on all files.

### `prune`

`just prune` is a combination of all below `prune-*` commands,
running each of them in sequence:

#### `prune-dead-branches`

My preferred workflow is to work on short-lived feature branches,
merging those into the main branch via Pull Request,
with any CI checks (including pre-commit checks)
being required for the merge.
These then merge via squash commits back to main,
after which the branch is auto-deleted.

After that merge,
I'll `git switch main` back to the main branch,
`git pull` those remote changes,
and keep going on the next change.

This leaves local branches that serve no purpose,
since they've already been merged.
`just prune-dead-branches` will clean up these "dead" branches,
finding any local branch that tracks an upstream branch
that no longer exists.

This ignores local branches that have no tracked upstream branch.
Technically all it looks for is a branch (from a call to `git branch -v`)
that contains the text `[gone]`,
indicating its upstream is "gone".

#### `prune-tags`

Removes all git tags locally that no longer exist in the remote.

> [!warning]
> This actually deletes *all* local tags,
> then fetches remote tags again.
> If, for some reason, you have local tags not yet pushed,
> this will destroy them.

### `release-diff`

*alias: `reldif`*

> [!note]
> Requires the `gh` cli tool.

Prints a `git log` diff of commits
from the last release on GitHub
up to the current `HEAD`.

The latest release is determined using `gh release list`,
excluding drafts and pre-releases.
The tag of that release is passed to a `git log` call as `<tag>..HEAD`
to produce the list of commits.

The `git log` output is printed in a one-line custom format like so:

```
* <abbreviated-hash> <title>
```

The literal `*` to the left of each commit line acts as
Markdown format for a list.
Further, the `abbreviated-hash`
(colored green in the terminal for visibility)
creates an automatic link to the commit on GitHub
when the line is copied to any GitHub text field
(such as release notes or an issue comment).
