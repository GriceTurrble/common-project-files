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
sync-justfile:
    curl https://raw.githubusercontent.com/griceturrble/justfiles/main/Justfile > common.just
```

You can then call `just sync-justfile` to call down the common [Justfile](Justfile)
into the project.
From there, all targets of that common file should be available natively.

### gitignore the common file

This method will add a `common.just` file into your local repo.
You should add this file to `.gitignore` to avoid having it tracked.
