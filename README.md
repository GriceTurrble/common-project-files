# justfiles
My common justfile recipes which I use for imports across projects

## Usage

> [!note]
> Refer to [Just docs](https://just.systems/man/en/remote-justfiles.html#remote-justfiles)
> for details on using remote Justfiles.

Include the following in the project Justfile:

```just
import? 'common.just'

# Show these help docs
help:
    @just --list --unsorted --justfile {{ source_file() }} 

# Pull latest common justfile recipes to local repo
[group("commons")]
sync-justfile:
    curl https://raw.githubusercontent.com/griceturrble/justfiles/main/Justfile > common.just
```

You can then call `just sync-justfile` to call down the common [Justfile](Justfile)
into the project.
From there, all targets of that common file should be available natively.

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
